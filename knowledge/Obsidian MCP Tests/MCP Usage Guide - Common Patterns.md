# MCP Usage Guide - Common Patterns

> **Status**: ✅ Active Integration  
> **Updated**: 2025-08-27  
> **Related**: [[How It Works - Technical Deep Dive]] | [[WORKING Setup - Clean Path Solution]]

## Overview

This guide covers the most common patterns for using the MCP (Model Context Protocol) Obsidian integration. These patterns have been tested and validated in our working setup.

## 📁 File Management Patterns

### Creating Files

**Basic File Creation**
```markdown
Action: vault(action='create', path='<path>', content='<content>')
Use Case: Creating new notes with structured content
Example: vault(action='create', path='Daily Notes/2025-08-27.md', content='# Daily Note\n\n## Tasks\n- [ ] Review MCP documentation')
```

**Template-Based Creation**
```markdown
Action: vault(action='create', path='<path>', content='<template>')
Use Case: Creating files from predefined templates
Pattern: Store common templates as variables, reuse across files
Example: Meeting note templates, project templates, daily note templates
```

### Reading Files

**Single File Read**
```markdown
Action: vault(action='read', path='<filename>')
Use Case: Viewing complete file contents
Best Practice: Use for files under 1000 lines for optimal performance
```

**Fragment-Based Reading**
```markdown
Action: vault(action='fragments', path='<filename>', maxFragments=5)
Use Case: Getting relevant excerpts from large files
Optimization: Reduces context usage while maintaining relevance
```

**Reading with Context**
```markdown
Action: vault(action='read', path='<filename>')
Follow-up: Use fragments for related files based on content
Pattern: Read main file, then fragment-read related files for context
```

### Updating Files

**Direct Content Updates**
```markdown
Action: edit(action='patch', path='<filename>', oldText='<existing>', newText='<replacement>')
Use Case: Specific content modifications
Best Practice: Use precise text matching for reliable updates
```

**Appending Content**
```markdown
Action: edit(action='append', path='<filename>', content='<new_content>')
Use Case: Adding new sections or entries
Common Usage: Daily notes, logs, running lists
```

**Targeted Updates**
```markdown
Action: edit(action='patch', path='<filename>', target='<heading>', targetType='heading', operation='append', newText='<content>')
Use Case: Adding content under specific headings
Pattern: Maintain document structure while adding new information
```

### File Discovery

**Pattern-Based Listing**
```markdown
Action: vault(action='list', directory='<path>')
Use Case: Exploring directory structure
Follow-up: Often combined with search for content discovery
```

**Content-Based Discovery**
```markdown
Action: vault(action='search', query='<terms>', includeContent=true)
Use Case: Finding files containing specific information
Optimization: Use includeContent=false for faster file discovery
```

## 🔍 Search Patterns

### Basic Search Operations

**Simple Term Search**
```markdown
Action: vault(action='search', query='keyword')
Use Case: Finding all files containing a term
Pattern: Start broad, then narrow with additional terms
```

**Multi-term Search**
```markdown
Action: vault(action='search', query='term1 term2')
Use Case: Finding files containing multiple concepts
Behavior: Boolean AND logic by default
```

**Phrase Search**
```markdown
Action: vault(action='search', query='"exact phrase"')
Use Case: Finding specific text strings
Best Practice: Use for technical terms, quotes, or precise references
```

### Advanced Search Patterns

**Content-Inclusive Search**
```markdown
Action: vault(action='search', query='<terms>', includeContent=true, pageSize=10)
Use Case: Getting search results with context snippets
Trade-off: Slower but provides immediate context
```

**Fragment-Based Search**
```markdown
Action: vault(action='fragments', query='<terms>', maxFragments=5, strategy='semantic')
Use Case: Getting the most relevant excerpts from search results
Optimization: Best for large knowledge bases
```

**Paginated Search**
```markdown
Action: vault(action='search', query='<terms>', page=1, pageSize=20)
Use Case: Managing large result sets
Pattern: Start with page 1, increase pageSize for broader coverage
```

## 🔄 Common Workflows

### Research and Note-Taking

**1. Topic Research Workflow**
```markdown
Step 1: vault(action='search', query='topic keywords')
Step 2: vault(action='fragments', path='relevant_file.md', maxFragments=3)
Step 3: vault(action='create', path='Research/Topic Summary.md', content='compiled_research')
```

**2. Cross-Reference Building**
```markdown
Step 1: vault(action='read', path='main_note.md')
Step 2: vault(action='search', query='related concepts')
Step 3: edit(action='append', path='main_note.md', content='## Related Notes\n- [[link1]]\n- [[link2]]')
```

### Content Organization

**1. Tag-Based Organization**
```markdown
Pattern: Search for untagged content
Action: vault(action='search', query='content without #tags')
Follow-up: Add appropriate tags via edit operations
Result: Improved discoverability and organization
```

**2. Structure Creation**
```markdown
Step 1: vault(action='list', directory='target_folder')
Step 2: vault(action='create', path='Index.md', content='# Folder Index\n\n')
Step 3: Loop through files, append links to index
Result: Navigable folder structure
```

### Daily Operations

**1. Daily Note Creation**
```markdown
Pattern: Template-based daily notes
Template: '# Daily Note - {date}\n\n## Tasks\n\n## Notes\n\n## Reflections'
Action: vault(action='create', path='Daily Notes/{date}.md', content=template)
```

**2. Weekly Review**
```markdown
Step 1: vault(action='search', query='last 7 days tasks')
Step 2: vault(action='fragments', path='relevant_daily_notes', maxFragments=10)
Step 3: vault(action='create', path='Reviews/Week-{date}.md', content='compiled_review')
```

## 💡 Performance Tips

### Optimization Strategies

**Fragment Over Full Read**
- Use `fragments` for large files (>500 lines)
- Set appropriate `maxFragments` (3-7 typically optimal)
- Choose `strategy='semantic'` for content relevance

**Search Optimization**
- Use `includeContent=false` for discovery phase
- Add `includeContent=true` only when context is needed
- Implement pagination for large result sets

**Batch Operations**
- Group related file operations together
- Use search to identify targets before bulk operations
- Consider rate limiting for large-scale updates

### Memory Management

**Context-Aware Reading**
```markdown
Large Files: Use fragments first, full read only if necessary
Multiple Files: Prioritize most relevant, fragment the rest
Search Results: Use pagination to avoid overwhelming context
```

**Strategic Caching**
```markdown
Pattern: Read frequently accessed files early in session
Benefit: Reduces repeated API calls
Implementation: Store key templates and references in session
```

## ⚠️ Common Pitfalls and Solutions

### Path Issues
**Problem**: File not found errors
**Solution**: Use `vault(action='list')` to verify paths
**Prevention**: Start with directory listing for path validation

### Content Matching
**Problem**: Edit operations failing due to text mismatches
**Solution**: Use exact text from read operations
**Prevention**: Copy-paste exact text for oldText parameters

### Performance Issues
**Problem**: Slow responses with large files
**Solution**: Use fragments instead of full reads
**Prevention**: Check file sizes, default to fragment strategy

### Search Relevance
**Problem**: Too many irrelevant search results
**Solution**: Use more specific query terms, add context
**Prevention**: Start with broad search, refine iteratively

## 🎯 Next Steps

- **Advanced Patterns**: See [[MCP Advanced Scenarios - Use Cases]]
- **Best Practices**: See [[MCP Best Practices - Tips and Tricks]]
- **Technical Details**: See [[How It Works - Technical Deep Dive]]

---

**Usage Notes:**
- All patterns tested with working MCP integration
- Examples use real command syntax
- Performance tips based on actual usage
- Common pitfalls from real-world experience

*Generated with MCP integration - demonstrating the patterns described above*