# MCP Investigation Template

> **Agent**: Use this template for systematic investigation  
> **Goal**: Establish ground truth about MCP setup  
> **Rule**: Ask questions instead of guessing

## 🔍 Investigation Checklist

### Phase 1: User Questions (REQUIRED FIRST)

**Questions to ask user immediately:**
- [ ] What MCP server are we actually using?
- [ ] How was it installed? (BRAT / npm / docker / other)
- [ ] What connection method? (REST API / direct / other)
- [ ] Can you show exact installation steps?
- [ ] What does `claude mcp list` show exactly?
- [ ] Which Obsidian plugins handle MCP functionality?

**User Responses:**
```
[Document user answers here - don't proceed without them]
```

### Phase 2: Technical Verification

**System Investigation:**
```bash
# MCP Status Check
claude mcp list
Result: [paste exact output]

# Plugin Directory
mcp__obsidian__vault(action="list", directory=".obsidian")
Found: [list what you found]

# Community Plugins  
mcp__obsidian__vault(action="read", path=".obsidian/community-plugins.json")  
Plugins: [list installed plugins]

# Search for MCP references
mcp__obsidian__vault(action="search", query="MCP OR REST OR semantic")
References: [summarize findings]
```

**Findings:**
- **MCP Server Type**: [npm package / native plugin / other]
- **Installation Method**: [BRAT / npm / manual / unknown]  
- **Connection Method**: [REST API / direct / unknown]
- **Working Status**: [confirmed working / issues found / unknown]

### Phase 3: Documentation Audit

**Current Documentation Claims:**
- [ ] Technical Deep Dive says: [what it claims]
- [ ] Usage Guide says: [what it claims] 
- [ ] Best Practices says: [what it claims]
- [ ] Setup docs say: [what they claim]

**Discrepancies Found:**
```
Doc A claims X, but Doc B claims Y
User says Z, but docs claim W  
System shows P, but docs claim Q
```

### Phase 4: Gap Analysis

**What We Know For Sure:**
- [List only verified facts]

**What Needs Clarification:**
- [List specific unknowns that require user input]

**What Contradicts:**
- [List conflicting information sources]

## 📋 Evidence Documentation

### User Statements
```
[Paste exact user responses - don't paraphrase]
```

### System Evidence  
```
[Paste exact command outputs and file contents]
```

### Documentation References
```
[Quote exact text from conflicting documentation]
```

## 🎯 Next Steps

**If Investigation Complete:**
- [ ] All user questions answered
- [ ] Technical findings match user statements  
- [ ] Discrepancies clearly documented
- [ ] Ready to correct documentation

**If Need More Information:**
- [ ] Specific questions identified for user
- [ ] Technical gaps documented
- [ ] Investigation paused until clarification

**Questions Still Needed:**
1. [Specific question about X]
2. [Specific question about Y]
3. [Specific question about Z]

---

**Investigation Status**: [In Progress / Complete / Blocked]  
**Next Action**: [Ask user questions / Investigate technical / Update docs / Wait for clarification]

*Template for systematic MCP setup investigation - use this to ensure thoroughness*