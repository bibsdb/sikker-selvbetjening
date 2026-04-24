# About This Documentation

## Overview

This documentation site provides a comprehensive reference for the JSON Schema definitions used in the sikker-selvbetjening fleet configuration system.

## Schema Design Philosophy

The schemas follow these principles:

- **Hierarchical**: Root schema references section-specific subschemas
- **Self-documenting**: Every property includes descriptions for clarity
- **Strict validation**: `additionalProperties: false` enforces explicit schema adherence
- **Extensible**: New sections can be added without modifying the root schema

## Technology Stack

- **Schema Standard**: [JSON Schema Draft 2020-12](https://json-schema.org/draft/2020-12/schema)
- **Documentation Generator**: [MkDocs](https://www.mkdocs.org/) with [Material Theme](https://squidfunk.github.io/mkdocs-material/)
- **Deployment**: GitHub Pages (auto-deployed on schema changes via GitHub Actions)
- **Validation**: JSON Schema validation + custom Python validator for cross-field constraints
