# Quarto-tikz

## Overview

This is a Quarto extension that allow tikz code directly to be rendered as image
similar to Mermaid or Graphviz diagram.

## Installation

To install this extension in your current directory (or into the Quarto project that you're currently working in),  use the following command:

```
quarto install extension Silvanosky/quarto-tikz
```

## Usage

#### Example

```markdown
---
title: Tikz figures
format:
   html: default
filters:
   - quarto-tikz
---

::: {#fig-test}
\`\`\`{tikz}
\begin{tikzpicture}

\def \n {5}
\def \radius {3cm}
\def \margin {8} % margin in angles, depends on the radius

\foreach \s in {1,...,\n}
{
  \node[draw, circle] at ({360/\n * (\s - 1)}:\radius) {$\s$};
  \draw[->, >=latex] ({360/\n * (\s - 1)+\margin}:\radius)
    arc ({360/\n * (\s - 1)+\margin}:{360/\n * (\s)-\margin}:\radius);
}
\end{tikzpicture}
\`\`\`


Test
:::

```

