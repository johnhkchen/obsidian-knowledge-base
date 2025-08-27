# MCP Best Practices - Tips and Tricks

> **Status**: ✅ Active Integration  
> **Updated**: 2025-08-27  
> **Related**: [[MCP Usage Guide - Common Patterns]] | [[How It Works - Technical Deep Dive]]

## Overview

This guide contains battle-tested best practices, optimization techniques, and practical tips for maximizing productivity with the MCP Obsidian integration.

## 🚀 Performance Optimization

### Smart Reading Strategies

**Fragment-First Approach**
```markdown
✅ BEST: vault(action='fragments', path='large_file.md', maxFragments=5)
❌ AVOID: vault(action='read', path='large_file.md') for files >500 lines

Reason: Fragments provide targeted content without context overload
Result: 3-5x faster response times for large files
```

**Strategic Fragment Configuration**
```markdown
For Research: maxFragments=3, strategy='semantic'
For Overview: maxFragments=7, strategy='adaptive'
For Precision: maxFragments=2, strategy='proximity'

Tip: Start with semantic, adjust based on result quality
```

**Content-Aware Pagination**
```markdown
Discovery Phase: pageSize=20, includeContent=false
Analysis Phase: pageSize=10, includeContent=true
Deep Dive: pageSize=5, includeContent=true, fragments for each result
```

### Search Optimization Techniques

**Query Refinement Patterns**
```markdown
Level 1: Single broad term ('productivity')
Level 2: Multiple terms ('productivity habits daily')
Level 3: Quoted phrases ('productivity habits' AND 'daily routine')
Level 4: Exclusion ('productivity -social -media')

Tip: Start broad, refine progressively
```

**Search Result Management**
```markdown
✅ EFFICIENT:
1. Search with includeContent=false (fast discovery)
2. Fragment the most relevant 3-5 results
3. Full read only for primary sources

❌ INEFFICIENT:
1. Search with includeContent=true immediately
2. Read every result file completely
3. No prioritization of results
```

## 🎯 Workflow Optimization

### Session-Based Strategies

**Information Architecture**
```markdown
Start-of-Session:
1. vault(action='list') for current directory structure
2. Search for recent updates (past 7 days)
3. Fragment key reference documents

Benefits: Establishes context, reduces repeated lookups
```

**Batch Processing Patterns**
```markdown
Efficient Batching:
1. Collect all target files via search
2. Group similar operations (all reads, then all edits)
3. Process in logical order (dependencies first)

Example:
- Search for all daily notes from last week
- Fragment each for key themes
- Create weekly summary with compiled insights
```

### Content Organization Best Practices

**Link Building Strategy**
```markdown
Progressive Linking:
1. Create content first, optimize later
2. Use search to find related existing content
3. Add bidirectional links systematically
4. Build index pages for major topics

Pattern: Content → Discovery → Connection → Index
```

**Tag Management**
```markdown
Systematic Tagging:
1. Search for untagged content by topic area
2. Establish tag hierarchies (#work/projects/active)
3. Use consistent tag formats across vault
4. Create tag index pages for navigation

Tip: Use search to audit tag consistency
```

## 💡 Advanced Techniques

### Template Systems

**Dynamic Template Creation**
```markdown
Base Template Storage:
vault(action='create', path='Templates/Base.md', content=template_content)

Template Application:
1. Read template file
2. Replace variables with context-specific values
3. Create new file with populated template

Variables: {date}, {title}, {tags}, {project}
```

**Template Evolution**
```markdown
Pattern: Start simple, evolve based on usage
1. Create basic templates first
2. Identify common modifications
3. Add variables for frequent changes
4. Build library of specialized templates

Result: Consistent structure + flexibility
```

### Cross-Vault Insights

**Content Analytics**
```markdown
Usage Patterns:
1. Search for frequently referenced terms
2. Analyze file creation dates/patterns
3. Identify orphaned content (no links)
4. Track content evolution over time

Tools: Combine search + fragment analysis
```

**Knowledge Gap Detection**
```markdown
Gap Analysis Process:
1. Search for questions without answers ('?', 'how to', 'why')
2. Find topics mentioned but not detailed
3. Identify broken or missing links
4. Spot areas with thin content

Action: Prioritize content creation based on gaps
```

## ⚡ Speed Tips

### Quick Operations

**Rapid File Creation**
```markdown
Speed Technique: Pre-define common structures
Daily: vault(action='create', path='Daily/{today}.md', content=daily_template)
Meeting: vault(action='create', path='Meetings/{title}.md', content=meeting_template)
Project: vault(action='create', path='Projects/{name}/README.md', content=project_template)
```

**Fast Content Updates**
```markdown
Append Strategy for Running Lists:
edit(action='append', path='Lists/Ideas.md', content='\n- {new_idea}')
edit(action='append', path='Daily/{today}.md', content='\n## {time}: {note}')

Benefit: No need to read/parse existing content
```

### Keyboard Shortcuts Mental Models

**Command Patterns to Memorize**
```markdown
Discovery: list → search → fragments
Creation: create → append/edit → link
Analysis: fragments → read → cross-reference
Organization: search → batch-edit → index-update
```

## 🛠️ Error Handling and Recovery

### Common Issue Resolution

**File Not Found Errors**
```markdown
Debug Process:
1. vault(action='list', directory=parent_path)
2. Verify exact file names and extensions
3. Check for hidden characters or encoding issues
4. Use search as fallback discovery method

Prevention: Always list directory contents first
```

**Edit Operation Failures**
```markdown
Text Matching Issues:
1. Use exact text from read operations
2. Account for invisible characters (tabs, spaces)
3. Consider using line-based edits for precision
4. Fall back to append operations when patch fails

Tip: Copy-paste text directly from read results
```

**Performance Degradation**
```markdown
Response Time Issues:
1. Check file sizes (fragment large files)
2. Reduce pageSize for searches
3. Use includeContent=false for discovery
4. Clear session context if needed

Monitor: Response times >5 seconds indicate optimization needed
```

### Backup and Safety

**Content Safety Patterns**
```markdown
Before Bulk Operations:
1. Create backup or checkpoint
2. Test on single file first
3. Use version control (git) for tracking
4. Keep operation logs for rollback

Safety First: Always test destructive operations
```

## 🎨 Creative Usage Patterns

### Automation Workflows

**Content Generation Pipelines**
```markdown
Research → Synthesis → Publication:
1. Search and fragment source materials
2. Create synthesis document
3. Generate structured output
4. Link to source materials

Example: Weekly newsletter from daily notes
```

**Maintenance Automation**
```markdown
Regular Maintenance Tasks:
- Search for outdated content (dates, links)
- Update index pages with new content
- Reorganize tags and categories
- Clean up orphaned files

Schedule: Weekly vault health checks
```

### Knowledge Synthesis

**Topic Clustering**
```markdown
Cluster Discovery:
1. Search broad topic terms
2. Fragment results for key themes
3. Identify connection patterns
4. Create topic overview pages

Result: Emergent knowledge structure
```

**Cross-Domain Insights**
```markdown
Connection Discovery:
1. Search for concepts across different domains
2. Look for pattern similarities
3. Create bridge content linking domains
4. Build meta-knowledge structures

Value: Unexpected insights from diverse connections
```

## 🔧 Troubleshooting Quick Reference

### Performance Issues
- **Slow responses**: Use fragments instead of full reads
- **Large result sets**: Implement pagination
- **Context overflow**: Reduce maxFragments or pageSize

### Content Issues
- **Missing files**: Use list/search for path verification
- **Edit failures**: Copy exact text from read operations
- **Search relevance**: Refine query terms, use quotes for phrases

### Workflow Issues
- **Broken automation**: Test each step individually
- **Inconsistent results**: Standardize query patterns
- **Organization problems**: Create systematic tagging/linking

## 🎯 Pro Tips Summary

**Daily Practice**
1. Start sessions with directory listing
2. Use fragments for exploration, full read for action
3. Build templates for recurring patterns
4. Maintain consistent naming conventions

**Weekly Optimization**
1. Review search patterns for efficiency
2. Update templates based on usage
3. Clean up orphaned content
4. Analyze workflow bottlenecks

**Monthly Strategy**
1. Evaluate overall vault organization
2. Optimize frequently-used workflows
3. Update best practices based on learning
4. Plan structural improvements

---

**Remember**: These practices evolved from real usage - adapt them to your specific needs and workflows.

*This document practices what it preaches - created using the MCP patterns it describes.*