# Workflow Patterns

Use these patterns when skills need to guide Claude through multi-step processes.

## Sequential Workflows

Break complex tasks into clear, sequential steps. Provide an overview of the process towards the beginning of SKILL.md.

**Example: PDF Form Filling**

```markdown
## Workflow

1. Analyze the form (run analyze_form.py)
2. Create field mapping (edit fields.json)
3. Validate mapping (run validate_fields.py)
4. Fill the form (run fill_form.py)
5. Verify output (run verify_output.py)
```

### Best Practices

- Number steps explicitly
- Reference specific scripts or tools at each step
- Include expected inputs and outputs for each step
- Note where human review or input is needed

## Conditional Workflows

For tasks involving branching logic, direct Claude through decision points:

```markdown
## Workflow Decision Tree

- **Creating new content?** → Follow "Creation workflow" below
- **Editing existing content?** → Follow "Editing workflow" below

### Creation workflow
1. Gather requirements
2. Generate draft
3. Review and refine

### Editing workflow
1. Analyze existing content
2. Identify changes needed
3. Apply modifications
4. Verify changes
```

### Best Practices

- Present decision points as clear questions
- Link to the appropriate sub-workflow
- Keep branching shallow (2-3 levels max)
- Provide fallback guidance for edge cases
