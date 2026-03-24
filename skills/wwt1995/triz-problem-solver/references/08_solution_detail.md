# Solution Detail Generation

## Task

Based on the concept solution selected by the user, generate complete solution details in one pass, including the solution name, working principle, technology grafting, solution conversion logic, implementation method, and a mermaid-format implementation flowchart.

---

## Input Information

Retrieve the following data from preceding steps:

- **User problem**: Confirmed core problem / improvement goal
- **Key problem**: Description of the causal chain key problem that the user's selected solution belongs to
- **Concept solution**: Complete concept solution data selected by the user, including solution title, solution summary, advantage tags, applied TRIZ principles, feasibility rating, analysis method, whether cross-domain, and associated patent feature mapping information
- **Component analysis**: System component inventory and functional descriptions
- **Functional model**: Functional modeling results
- **Patent information**: Reference patent data associated with the concept solution, including patent title, feature type, feature content, and application method

---

## Execution Method

Invoke the `triz_analysis` MCP tool to complete this task:

```bash
bash scripts/call_triz_analysis.sh "solution_detail" "<user_input>"
```

`user_input` uses tags to distinguish each section:
```
[User Problem]
{core problem / improvement goal}

[Key Problem]
{causal chain key problem description}

[Concept Solution]
{complete concept solution data selected by the user}

[Component Analysis]
{system component inventory and functional descriptions}

[Functional Model]
{functional modeling results}

[Patent Information]
{associated reference patent data}
```

---

## Output Format

The tool returns a JSON string with the structure `{"content": "..."}`. Extract the solution details from the `content` field. The result is displayed in Markdown format:

```
## Solution Details: [solution_name]

### Working Principle
[principle_of_work]

### Technology Grafting Description
- **Patent [PN]**: [description]

### Solution Conversion Logic
[solution_rationale]

### Specific Implementation Method
[implementation]

### Implementation Flowchart
[mermaid flowchart]
```
