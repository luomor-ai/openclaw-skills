# System Component Analysis

## Task

Based on the complete technical problem description provided by the user, use the TRIZ functional analysis method to systematically identify and classify all key components (system components and supersystem components), clarify the main functional description of each component, and provide an accurate functional model for subsequent TRIZ analysis.

- If there is no modification request, treat this as a first-time generation task and output results directly based on the problem summary
- If a modification request exists, understand the user's modification intent, adjust based on existing results, and re-output

---

## Input Information

- **Problem summary**: The complete technical problem description provided by the user, clarified and confirmed
- **Modification request** (optional): User-provided modification content, supplied in modification scenarios
- **Existing data** (optional): Previously generated system component analysis content, supplied in modification scenarios

---

## Execution Method

Invoke the `triz_analysis` MCP tool to complete this task:

```bash
bash scripts/call_triz_analysis.sh "system_component_analysis" "<user_input>"
```

`user_input` uses tags to distinguish each section:
```
[Problem Summary]
{problem summary content}

// Append the following in modification scenarios
[Modification Request]
{user's modification content}

[Existing Data]
{previously generated system component analysis content}
```

---

## Output Format

The tool returns a JSON string with the structure `{"content": "..."}`. Extract the system component analysis result from the `content` field. The result is a system component inventory in Markdown table format, containing two sections — system components and supersystem components — with each component including a number, name, type, and main functional description.

### Example (using "heat exchanger frosting causing efficiency degradation" as an example)

#### System Components

| No. | Component Name | Type | Main Functional Description |
|------|----------|------|-------------|
| S1 | Fin-type heat exchanger | Substance | Extends surface area through fins to transfer refrigerant cooling capacity to air |
| S2 | Refrigerant | Substance | Flows inside the heat exchanger, absorbs external heat to achieve cooling |
| S3 | Frost layer | Substance | Ice crystal layer formed by condensation of water vapor in air on low-temperature fin surfaces, impeding heat exchange |
| F1 | Thermal field (heat exchange) | Field | Drives heat exchange between refrigerant and air |

#### Supersystem Components

| No. | Component Name | Type | Main Functional Description |
|------|----------|------|-------------|
| S4 | Ambient air | Substance | Acts as a heat source, supplying airflow to be cooled to the heat exchanger |
| S5 | Compressor | Substance | Provides circulation power for the refrigerant, maintaining the refrigeration cycle |
| F2 | Humidity field | Field | Water vapor carried by ambient air, the material source of frost layer formation |
| P1 | Ambient temperature | Parameter | Key environmental parameter affecting heat exchange temperature difference and frosting rate |
