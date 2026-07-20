# ADR 0008: GXE Arrival To Product Light-Bloom Transition

Status: Superseded by ADR 0009
Date: 2026-06-26

This record preserves the earlier cinematic city-arrival direction. ADR 0009
replaces its arrival and interaction while retaining the two-scene structure,
bloom-masked handoff, and product reveal as the destination.

## Context
The earlier GXE V1 transition moved GXE from the center into an upper-left
architectural position while the city and product became visible in the same
scene.

The revised direction simplifies the experience into two distinct scenes while
making the entrance more memorable. GXE should feel like a chrome pendant,
suspended jewel, or moon above a stylized city rather than a logo placed on a
web page.

## Decision
GXE V1 will use an arrival scene followed by a light-bloom transition into a
product reveal scene.

Arrival scene:

- The mobile-first view looks upward between tall, dark, stylized buildings.
- GXE sits high in the sky as the primary focal object.
- GXE is chrome, reflective, glistening, premium, and always visually active.
- The city establishes scale, anticipation, and atmosphere without becoming the
  subject.
- A visible text entry control replaces the double-tap interaction. The default
  V1 wording is `Enter GXE`, with final campaign copy remaining adjustable.
- The entry control should be easy to find but visually quiet, without looking
  like a conventional boxed button.

Transition:

```text
user enters GXE
GXE catches and throws increasingly dramatic reflected glints
the view makes a subtle push toward GXE
restrained purple constellation energy becomes visible behind GXE
GXE brightness expands into a full-frame bloom
the bloom briefly hides the scene change
the product reveal scene resolves from the light
```

GXE may borrow the behavior of a disco ball by catching and scattering small
fragments of light, but it should not become a literal disco ball. The effect
must remain jewelry-like and fashion-focused.

The surrounding skyscrapers may carry a subtle party influence through a few
restrained reflected light fragments, faint rhythmic window accents, or brief
surface catches caused by GXE. They should remain dark architectural masses,
not become colorful club scenery, screens, signs, or animated light shows.

Product reveal scene:

- GXE is no longer visible after the bloom.
- The featured piece becomes the clear destination and dominant subject.
- GXE remains conceptually present through light rising from the podium or from
  beneath the piece.
- Purple energy may remain as a dim secondary background layer.
- The scene should avoid carrying over unnecessary city detail from arrival.

## Why
This direction gives GXE a stronger entrance and creates a clean handoff from
brand to product. The bloom makes the scene change feel caused by GXE rather
than by ordinary page navigation.

It also supports the brand principle:

```text
GXE illuminates the world. The world exists to showcase the piece.
```

GXE first commands the sky, then its light becomes the mechanism that reveals
and favors the featured piece.

## Alternatives Considered
Keep the upper-left architectural emblem transition:

- Preserves one continuous world.
- Makes the arrival and product compete within the same composition.

Keep double tap as the entry action:

- More hidden and mysterious.
- Risks being missed and makes GXE behave more like an unlabeled control.

Show the purple constellation immediately:

- Makes the sky richer on arrival.
- Weakens the chrome-first hierarchy and the purple layer's role as a later
  discovery.

Use a literal disco-ball treatment:

- Connects directly to the party concept.
- Risks making the experience feel inexpensive, playful, or nightclub-themed
  instead of premium and fashion-focused.

## Consequences
ADR 0004 is superseded. GXE no longer moves into the upper-left corner, remains
visible beside the product, or reveals the product within the arrival city.

The implementation can remain inside the isolated GXE prototype, but its CSS
and interaction states will need to represent two scenes and one bloom-masked
handoff.

Timing becomes important: the glisten and subtle push-in need enough buildup to
make GXE feel intentional, while the bloom must be long enough to hide the scene
change without feeling slow or uncomfortable.

The exact entry phrase, amount of skyline reflection, bloom timing, and product
podium lighting remain tunable visual details rather than new architectural
decisions.

## Related Files
- templates/gxe/layout.html
- templates/gxe/assets/style.css
- templates/gxe/assets/experience.js
- content/profiles/gxe.json
- docs/CURRENT_WORK.md
- docs/decisions/0003-gxe-visual-layer-separation.md
- docs/decisions/0004-gxe-v1-experience-transition.md
