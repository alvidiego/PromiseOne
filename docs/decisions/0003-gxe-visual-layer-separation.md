# ADR 0003: GXE Visual Layer Separation

Status: Accepted; arrival timing and combined-reference use amended by ADR 0009
Date: 2026-06-12

ADR 0009 changes when GXE becomes visible, not the separation between chrome
GXE and purple energy. GXE is conceptually present from the beginning but is
visually discovered through the press-and-hold ice-out sequence.

## Context
The GXE logo reference combines chrome GXE letters with a purple star/energy shape. During design exploration, these were clarified as separate visual identities.

Brand principle:

```text
GXE illuminates the world. The world exists to showcase the piece.
```

## Decision
The GXE pendant and the purple energy layer are separate.

GXE pendant identity:

- Chrome
- Reflective
- Glistening
- Premium
- Jewelry-like
- High-contrast
- Conceptually active before it is visible
- Primary visual focus during the arrival reveal

Purple energy layer:

- Secondary
- Not visible at initial arrival
- Revealed later
- Represents energy already present in the world
- Can use the purple star shape as traced background language
- Dim, atmospheric, and restrained

The purple star may also function as the visual structure holding the complete
GXE pendant together, provided it is revealed after the chrome-led buildup and
does not appear in the initial black frame.

The full combined JPG should not appear as the initial Stage 1 pendant. It may be
used as the completed ice-out payoff after the interaction has established the
chrome GXE letters first and revealed the purple star later.

## Why
If the purple star is included in the initial pendant, GXE itself starts to become the purple energy layer. That weakens the intended hierarchy.

The visual story is stronger when chrome GXE reveals the world, and purple energy appears as part of the world after the reveal.

## Alternatives Considered
Use the full JPG from the initial frame:

- Fast and faithful to the provided asset.
- Removes the intended discovery sequence and makes purple compete immediately.

Wait for perfect logo assets before continuing:

- Cleaner final asset path.
- Would slow down V1 experience testing.

Use a CSS chrome placeholder:

- Not final.
- Preserves the correct layer separation while waiting for better assets.

## Consequences
For V1, the full combined client reference may be used as a late-stage reveal to
preserve the exact lettering, stones, chrome, and structural purple star without
inventing obscured geometry from a limited raster reference.

Chrome and purple remain separate in timing and visual responsibility even when
they come from one combined source image.

The custom SVG reconstruction should remain available as an experiment but is
not the active V1 artwork unless it is approved later.

If the client provides separate files, prefer:

1. Chrome GXE letters only.
2. Purple star/energy shape only.
3. Full combined logo as a late-stage V1 reveal.

## Related Files
- templates/gxe/assets/style.css
- templates/gxe/assets/gxe-reference.jpg
- templates/gxe/assets/gxe-mark.svg
- content/profiles/gxe.json
- notes/incoming/GXE pfp (1).jpg
