"""Command line interface"""

import typer
from rich.console import Console
from rich.table import Table
from typing import Optional, List
from datetime import datetime

from .client import XiaohongshuClient
from .account import AccountManager

app = typer.Typer(help="Xiaohongshu MCP REST API Client")
console = Console()


# Account management commands
@app.command("account")
def account_command(
    action: str = typer.Argument(..., help="Action: list, add, remove, switch, import, current"),
    username: Optional[str] = typer.Option(None, help="Username (optional, auto-detect from current login if not provided)"),
    notes: Optional[str] = typer.Option(None, help="Account notes"),
    mcp_path: Optional[str] = typer.Option(".", help="MCP executable path"),
    base_url: Optional[str] = typer.Option(None, help="MCP server base URL"),
):
    """Manage accounts"""
    manager = AccountManager(mcp_exe_path=mcp_path)
    
    def get_current_nickname() -> Optional[str]:
        """Get current login nickname"""
        try:
            client = XiaohongshuClient(base_url=base_url)
            result = client.get_my_profile()
            if result.get("success"):
                data = result.get("data", {}).get("data", {})
                info = data.get("userBasicInfo", {})
                return info.get("nickname")
        except Exception:
            pass
        return None
    
    if action == "list":
        accounts = manager.list_accounts()
        if not accounts:
            console.print("[yellow]No accounts found[/yellow]")
            return
        
        table = Table(title="Accounts")
        table.add_column("Username")
        table.add_column("Last Used")
        table.add_column("Notes")
        table.add_column("Status")
        
        current = manager.get_current_account()
        for name, info in accounts.items():
            status = "[green]Current[/green]" if name == current else ""
            table.add_row(name, info.get("last_used", "N/A"), info.get("notes", ""), status)
        
        console.print(table)
        
    elif action == "add":
        if not username:
            username = get_current_nickname()
            if not username:
                console.print("[red]Username is required and cannot be auto-detected[/red]")
                return
        success = manager.import_cookies(username, notes or "")
        if success:
            # Set as current account after adding
            manager.switch_account(username)
            console.print(f"[green]Account {username} added successfully and set as current[/green]")
        else:
            console.print("[red]Failed to add account. Make sure cookies.json exists[/red]")
            
    elif action == "remove":
        if not username:
            console.print("[red]Username is required[/red]")
            return
        manager.remove_account(username)
        console.print(f"[green]Account {username} removed[/green]")
        
    elif action == "switch":
        if not username:
            console.print("[red]Username is required[/red]")
            return
        success = manager.switch_account(username)
        if success:
            console.print(f"[green]Switched to account {username}[/green]")
        else:
            console.print("[red]Failed to switch account[/red]")
            
    elif action == "import":
        if not username:
            username = get_current_nickname()
            if not username:
                console.print("[red]Username is required and cannot be auto-detected[/red]")
                return
        success = manager.import_cookies(username, notes or "")
        if success:
            console.print(f"[green]Cookies imported for account {username}[/green]")
        else:
            console.print("[red]Failed to import cookies[/red]")
            
    elif action == "current":
        current = manager.get_current_account()
        if current:
            console.print(f"[blue]Current account: {current}[/blue]")
        else:
            console.print("[yellow]No current account set[/yellow]")


# Login commands
@app.command("login")
def login_command(
    action: str = typer.Argument(..., help="Action: status, qrcode, logout"),
    base_url: Optional[str] = typer.Option(None, help="MCP server base URL"),
):
    """Manage login status"""
    client = XiaohongshuClient(base_url=base_url)
    
    if action == "status":
        result = client.check_login_status()
        if result.get("success"):
            data = result.get("data", {})
            if data.get("is_logged_in"):
                console.print(f"[green]✅ Logged in as: {data.get('username', 'Unknown')}[/green]")
            else:
                console.print("[red]❌ Not logged in[/red]")
        else:
            console.print(f"[red]❌ Error: {result.get('error', 'Unknown error')}[/red]")
            
    elif action == "qrcode":
        result = client.get_login_qrcode()
        if result.get("success"):
            console.print("[green]✅ QR code obtained. Check the MCP server output for the image[/green]")
        else:
            console.print(f"[red]❌ Error: {result.get('error', 'Unknown error')}[/red]")
            
    elif action == "logout":
        result = client.delete_cookies()
        if result.get("success"):
            console.print("[green]✅ Logged out successfully[/green]")
        else:
            console.print(f"[red]❌ Error: {result.get('error', 'Unknown error')}[/red]")


# Publish commands
@app.command("publish")
def publish_command(
    title: str = typer.Argument(..., help="Content title"),
    content: str = typer.Argument(..., help="Content body"),
    media: List[str] = typer.Argument(..., help="Image URLs or video path"),
    tags: Optional[List[str]] = typer.Option(None, help="Tags (comma-separated)"),
    visibility: Optional[str] = typer.Option(None, help="Visibility: 公开可见, 仅自己可见, 仅互关好友可见"),
    is_video: bool = typer.Option(False, help="Publish as video"),
    base_url: Optional[str] = typer.Option(None, help="MCP server base URL"),
):
    """Publish content"""
    client = XiaohongshuClient(base_url=base_url)
    
    try:
        if is_video:
            if len(media) != 1:
                console.print("[red]❌ Video publishing requires exactly one video file path[/red]")
                return
            result = client.publish_video(
                title=title,
                content=content,
                video=media[0],
                tags=tags,
                visibility=visibility
            )
        else:
            result = client.publish_content(
                title=title,
                content=content,
                images=media,
                tags=tags,
                visibility=visibility
            )
        
        if result.get("success"):
            console.print("[green]✅ Published successfully![/green]")
            if "post_id" in result.get("data", {}):
                console.print(f"Post ID: {result['data']['post_id']}")
        else:
            console.print(f"[red]❌ Error: {result.get('error', 'Unknown error')}[/red]")
    except Exception as e:
        console.print(f"[red]❌ Error: {str(e)}[/red]")


# Feed commands
@app.command("feed")
def feed_command(
    action: str = typer.Argument(..., help="Action: list, search, detail"),
    keyword: Optional[str] = typer.Option(None, help="Search keyword"),
    feed_id: Optional[str] = typer.Option(None, help="Feed ID"),
    xsec_token: Optional[str] = typer.Option(None, help="Xsec token"),
    base_url: Optional[str] = typer.Option(None, help="MCP server base URL"),
):
    """Manage feeds"""
    client = XiaohongshuClient(base_url=base_url)
    
    if action == "list":
        result = client.list_feeds()
        if result.get("success"):
            feeds = result.get("data", {}).get("feeds", [])
            console.print(f"[blue]📋 Found {len(feeds)} feeds:[/blue]")
            for i, feed in enumerate(feeds, 1):
                note = feed.get("noteCard", {})
                console.print(f"[{i}] {note.get('displayTitle', 'No title')}")
                console.print(f"    Author: {note.get('user', {}).get('nickname', 'Unknown')}")
                console.print(f"    Feed ID: {feed.get('id')}")
                console.print(f"    Xsec Token: {feed.get('xsecToken')}")
                console.print()
        else:
            console.print(f"[red]❌ Error: {result.get('error', 'Unknown error')}[/red]")
            
    elif action == "search":
        if not keyword:
            console.print("[red]❌ Keyword is required for search[/red]")
            return
        result = client.search_feeds(keyword=keyword)
        if result.get("success"):
            feeds = result.get("data", {}).get("feeds", [])
            console.print(f"[blue]🔍 Found {len(feeds)} feeds for '{keyword}':[/blue]")
            for i, feed in enumerate(feeds, 1):
                note = feed.get("noteCard", {})
                console.print(f"[{i}] {note.get('displayTitle', 'No title')}")
                console.print(f"    Author: {note.get('user', {}).get('nickname', 'Unknown')}")
                console.print(f"    Feed ID: {feed.get('id')}")
                console.print(f"    Xsec Token: {feed.get('xsecToken')}")
                console.print()
        else:
            console.print(f"[red]❌ Error: {result.get('error', 'Unknown error')}[/red]")
            
    elif action == "detail":
        if not feed_id or not xsec_token:
            console.print("[red]❌ Feed ID and Xsec token are required[/red]")
            return
        result = client.get_feed_detail(feed_id=feed_id, xsec_token=xsec_token)
        if result.get("success"):
            data = result.get("data", {}).get("data", {})
            note = data.get("note", {})
            console.print("[blue]📝 Note Details:[/blue]")
            console.print(f"Title: {note.get('title', 'No title')}")
            console.print(f"Author: {note.get('user', {}).get('nickname', 'Unknown')}")
            console.print(f"Content: {note.get('desc', 'No content')}")
            console.print(f"Likes: {note.get('interactInfo', {}).get('likedCount', '0')}")
            console.print(f"Comments: {note.get('interactInfo', {}).get('commentCount', '0')}")
        else:
            console.print(f"[red]❌ Error: {result.get('error', 'Unknown error')}[/red]")


# Interaction commands
@app.command("interact")
def interact_command(
    action: str = typer.Argument(..., help="Action: like, favorite, comment"),
    feed_id: str = typer.Argument(..., help="Feed ID"),
    xsec_token: str = typer.Argument(..., help="Xsec token"),
    content: Optional[str] = typer.Option(None, help="Comment content"),
    unlike: bool = typer.Option(False, help="Unlike"),
    unfavorite: bool = typer.Option(False, help="Unfavorite"),
    base_url: Optional[str] = typer.Option(None, help="MCP server base URL"),
):
    """Interact with feeds"""
    client = XiaohongshuClient(base_url=base_url)
    
    if action == "like":
        result = client.like_feed(feed_id=feed_id, xsec_token=xsec_token, unlike=unlike)
        if result.get("success"):
            console.print(f"[green]✅ {'Unliked' if unlike else 'Liked'} successfully![/green]")
        else:
            console.print(f"[red]❌ Error: {result.get('error', 'Unknown error')}[/red]")
            
    elif action == "favorite":
        result = client.favorite_feed(feed_id=feed_id, xsec_token=xsec_token, unfavorite=unfavorite)
        if result.get("success"):
            console.print(f"[green]✅ {'Unfavorited' if unfavorite else 'Favorited'} successfully![/green]")
        else:
            console.print(f"[red]❌ Error: {result.get('error', 'Unknown error')}[/red]")
            
    elif action == "comment":
        if not content:
            console.print("[red]❌ Comment content is required[/red]")
            return
        result = client.post_comment(feed_id=feed_id, xsec_token=xsec_token, content=content)
        if result.get("success"):
            console.print("[green]✅ Comment posted successfully![/green]")
        else:
            console.print(f"[red]❌ Error: {result.get('error', 'Unknown error')}[/red]")


# User commands
@app.command("user")
def user_command(
    action: str = typer.Argument(..., help="Action: me, profile"),
    user_id: Optional[str] = typer.Option(None, help="User ID"),
    xsec_token: Optional[str] = typer.Option(None, help="Xsec token"),
    base_url: Optional[str] = typer.Option(None, help="MCP server base URL"),
):
    """Manage user information"""
    client = XiaohongshuClient(base_url=base_url)
    
    if action == "me":
        result = client.get_my_profile()
        if result.get("success"):
            data = result.get("data", {}).get("data", {})
            info = data.get("userBasicInfo", {})
            console.print("[blue]👤 My Profile:[/blue]")
            console.print(f"Nickname: {info.get('nickname', 'Unknown')}")
            console.print(f"Bio: {info.get('desc', 'No bio')}")
            console.print(f"ID: {info.get('redId', 'Unknown')}")
            for interaction in data.get("interactions", []):
                console.print(f"{interaction.get('name')}: {interaction.get('count')}")
        else:
            console.print(f"[red]❌ Error: {result.get('error', 'Unknown error')}[/red]")
            
    elif action == "profile":
        if not user_id or not xsec_token:
            console.print("[red]❌ User ID and Xsec token are required[/red]")
            return
        result = client.get_user_profile(user_id=user_id, xsec_token=xsec_token)
        if result.get("success"):
            data = result.get("data", {}).get("data", {})
            info = data.get("userBasicInfo", {})
            console.print("[blue]👤 User Profile:[/blue]")
            console.print(f"Nickname: {info.get('nickname', 'Unknown')}")
            console.print(f"Bio: {info.get('desc', 'No bio')}")
            console.print(f"ID: {info.get('redId', 'Unknown')}")
            for interaction in data.get("interactions", []):
                console.print(f"{interaction.get('name')}: {interaction.get('count')}")
        else:
            console.print(f"[red]❌ Error: {result.get('error', 'Unknown error')}[/red]")


if __name__ == "__main__":
    app()
