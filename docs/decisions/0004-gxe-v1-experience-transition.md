# ADR 0004: GXE V1 Experience Transition

Status: Superseded by ADR 0008
Date: 2026-06-12

This record preserves the earlier V1 direction. The accepted arrival-to-product
transition is now documented in ADR 0008.

## Context
The GXE V1 experience has three conceptual stages:

1. Arrival: GXE is centered and important in a nearly black world.
2. Interaction: user double taps GXE.
3. Reveal: the world becomes understandable and the clothing becomes the hero.

The interaction should feel like discovery, not activation.

Desired feeling:

```text
The world was already there. The user simply perceives it differently.
```

## Decision
The Stage 1 to Stage 2 transition uses a subtle Parallax Reframe with Light-Catch Reveal.

Current V1 sequence:

```text
double tap
GXE glistens briefly
GXE transitions into upper-left architectural position
world architecture becomes more legible
purple energy appears as restrained background motion
clothing becomes illuminated and becomes the hero
```

The GXE mark should not feel like a button, UI element, or teleporting object.

## Why
This best supports the brand principle:

```text
GXE illuminates the world. The world exists to showcase the piece.
```

GXE starts as the focus, shows itself, then becomes the guide that reveals the stage and directs attention to the clothing.

## Alternatives Considered
Immediate movement on double tap:

- Simple and quick.
- Felt too much like a UI state change.

Dramatic zoom-out or camera flight:

- Cinematic.
- Too large and too distracting for the intended minimal mobile-first experience.

Product/card entering from below:

- Common web pattern.
- Made the clothing feel like a UI component instead of an object already present in the world.

## Consequences
GXE timing matters. Slower, intentional movement helped the transition feel more premium.

The product should be present before reveal as a dim silhouette, then become readable through light and contrast rather than entering like a card.

Future changes should preserve the sequence: GXE glistens first, then reveals context, then clothing becomes the destination.

The revealed architecture should quietly guide attention toward the featured piece. The world should act as a frame, not decoration. Nearby architectural forms can catch light, align visually, or create directional structure that leads the eye toward the clothing without using arrows, visible beams, or obvious UI cues.

During V1, lighting can lightly favor the center mass of the clothing placeholder, but refinements should not overfit to the placeholder's exact silhouette. The final product image will determine the more precise lighting relationship later.

## Related Files
- templates/gxe/assets/experience.js
- templates/gxe/assets/style.css
- templates/gxe/layout.html
- content/profiles/gxe.json
