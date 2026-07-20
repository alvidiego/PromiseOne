# ADR 0009: GXE Press-And-Hold Ice-Out Transition

Status: Accepted; destination amended by ADR 0010
Date: 2026-06-29

ADR 0010 preserves this first-visit ritual but changes its destination. The
product film will lead into a visit-aware GXE Main Menu instead of remaining the
final podium product page.

## Context
The two-scene GXE foundation and product reveal established under ADR 0008 work,
but the arrival and transition still feel like a conventional page change. The
experience needs a more interactive expression of GXE's jewelry identity before
the placeholder logo and background receive further visual refinement.

## Decision
GXE V1 will begin in a near-total black void with only a clear `Press and hold`
instruction visible. The initial city skyline and fully visible GXE emblem are
removed from the active arrival direction.

The hold interaction will reveal GXE progressively:

```text
user begins holding
one individual stone catches light
additional stones illuminate one by one
the illumination rhythm accelerates
the chrome GXE form becomes readable beneath the stones
the fully iced-out GXE is held briefly as the visual payoff
accumulated reflections become too intense
light expands to cover the complete frame
the product scene replaces the arrival beneath the light
the bloom recedes into the product podium illumination
```

The hold target should be large and mobile-friendly rather than requiring the
user to press a tiny word or stone. `Press and hold` remains visible guidance,
not a conventional boxed button.

GXE V1 is mobile-primary. Touch and phone-sized composition are the designed
experience. Desktop does not require an equally elaborate composition for V1,
but it must remain functional and accessible. A desktop visitor should be able
to hold Space or Enter from the page without first locating or focusing a small
control. Arbitrary keyboard keys should not trigger the reveal because accidental
activation would weaken the intentional hold interaction.

If the user releases before completion, the illuminated stones should fade back
into darkness and the instruction should return. Once the hold completes, the
transition proceeds automatically without requiring continued pressure.

The V1 arrival background remains black. Background architecture may be explored
later as something revealed by GXE's growing light, but it is not part of this
implementation pass.

Purple remains secondary. It should not be visible in the initial void and may
appear only as a restrained late edge in the ice-out buildup or within the
product scene.

V1 may use the complete client reference image as the final ice-out artwork. The
interaction should reveal chrome GXE first, then allow the purple star to emerge
behind it as the structure visually holding the letters together. At completion,
the full combined image may be visible briefly before its existing jewelry
highlights intensify into the bloom.

During the final portion of the ice-out, GXE gains an intentional circular aura.
The aura provides depth inside the black void and gives the completed jewelry a
brief angelic payoff before the transition. It remains absent early, forms behind
GXE rather than over the lettering, and expands naturally into the full-frame
bloom. Its recognizable circular shape is intentional, not a defect to remove.

The combined image's black background is acceptable for the mobile prototype
because it can blend into the black arrival. A direct original image is preferred,
but a clean crop from the available phone screenshot is acceptable if no better
source exists.

The interaction must support touch, mouse, and keyboard input. Reduced-motion
users should receive a shorter, non-accelerating reveal that still reaches the
product.

## Why
Press and hold makes the visitor participate in revealing GXE. The progressive
stones express the brand as jewelry instead of treating sparkle as decoration.

The accelerating ice-out creates anticipation, gives the complete GXE mark a
clear payoff, and makes the final bloom feel like a consequence of accumulated
reflection. The product then feels earned rather than merely navigated to.

Keeping the arrival black also reduces visual competition and allows the
transition to be proven before committing to a new background world.

## Alternatives Considered
Keep the `Enter GXE` tap and single-stone bloom:

- Simpler and accessible.
- Less participatory and does not fully express the jewelry reveal.

Keep the low-angle city arrival from ADR 0008:

- Provides immediate world-building and scale.
- Competes with the stone reveal and requires background refinement before the
  central interaction is proven.

Render every individual stone as a separate object:

- Could create detailed control over the sequence.
- Adds unnecessary markup, maintenance, and performance cost for V1. A limited
  set of deliberate light points can imply a fully iced surface.

Reconstruct the obscured letter geometry as the active V1 mark:

- Produces a scalable vector and allows precise future stone mapping.
- Requires guessing where sparkles and the purple star hide the original edges.
  The resulting candidate did not preserve the connected pendant closely enough
  to replace the available client reference.

Require the user to hold directly on GXE:

- Creates a direct object interaction.
- GXE begins visually concealed, making a small hidden target difficult to find.

## Consequences
ADR 0008 is superseded as the active arrival decision. Its separate product
scene, bloom-covered handoff, and GXE-to-podium lighting relationship remain in
force.

ADR 0003 remains active for chrome and purple layer separation, but GXE is no
longer fully visible on the first frame. It is active conceptually and becomes
the primary focus through interaction.

The current generated GXE arrival already implements the hold interaction and
preserves the Milestone 2 product scene, but it still uses the custom SVG
candidate. Implementation should replace only the active artwork and staged
reveal treatment while preserving the working hold and product destination.

The combined client reference is now the active V1 artwork direction. The custom
SVG reconstruction remains a reversible experiment and should not be deleted,
but it should not drive the active reveal.

The precise hold duration, number and placement of visible stone points, final
logo artwork, full-reveal pause, and bloom timing are tunable implementation
details. The target hold duration should remain short enough for mobile use,
approximately 1.8 to 2.2 seconds before automatic completion.

Orb V1 is part of the accepted reveal treatment. Future polishing may tune its
edge softness and intensity, but should preserve its depth, circular identity,
and late-stage relationship to the bloom.

Orb V1.1 keeps that accepted role and silhouette while improving material depth.
It uses a faint pearl-lit interior, a dimensional circular rim, and restrained
outer atmosphere rather than one uniformly bright ring. As the bloom begins, the
orb softens and expands into the whiteout so the two effects feel causally linked.
This is a material polish, not a new transition concept.

The accepted V1 handoff does not alter Orb V1 during its ice-out payoff. Once the
bloom fully covers the viewport, the arrival scene is removed beneath that cover
and the complete product scene takes its place. The bloom then recedes after a
brief hold, allowing the podium and environmental light to establish first, the
featured piece to resolve next, and supporting copy to arrive last. This prevents
a ghosted GXE frame and makes the transition feel continuous rather than like a
page crossfade.

The product destination uses the supplied vertical product video as a short,
one-time reveal rather than a continuously looping player. Playback begins near
9.6 seconds so the final five seconds show both sides of the same GXE car shirt,
then ends on its centered final frame. It remains muted, inline, and free of
native controls. Reduced-motion users receive a stable final product frame.
The video is profile-declared, while timing and playback remain owned by the GXE
theme. This preserves the profile-to-theme boundary established by ADR 0002.

For local servers that do not support reliable video seeking, the theme may
advance the clip at an increased rate while the arrival and bloom still conceal
it. The concealed pre-roll slows near the configured reveal time and pauses there
until the product scene is ready, then the visible sequence resumes at normal
speed. Releasing the hold early resets the concealed video to its initial state.
This implementation detail must preserve the front-and-back sequence and must not
turn the ending into a loop.

Supporting product copy remains hidden while the visible ending plays. Once the
video reaches its final frame, the product name and one short brand line may fade
in beneath the screen. Additional presentation labels, collection titles, and
sales controls are deferred until real product content requires them. Subtle
podium depth and ground reflection may imply an outdoor projection environment,
but the product destination should not introduce a literal projector or theater.

Final jewelry highlights remain localized to the actual G, X, and E artwork.
A full-width traveling glare should not cross the emblem; it reads as a graphic
overlay instead of reflected light. The completed client artwork, mapped stones,
three restrained light catches, and Orb V1 provide the final payoff.

Audio, haptics, a detailed background reveal, 3D stones, and real-time reflective
rendering are deferred.

A separate desktop art direction or desktop-specific cinematic composition is
also deferred. Desktop should receive the same core sequence through a simple
keyboard fallback while mobile remains the visual priority.

## Related Files
- templates/gxe/assets/style.css
- templates/gxe/assets/gxe-reference.jpg
- templates/gxe/assets/gxe-mark.svg
- templates/gxe/assets/experience.js
- templates/gxe/assets/gxe-product.mp4
- src/ai/content.lib.ps1
- content/profiles/gxe.json
- docs/CURRENT_WORK.md
- docs/decisions/0003-gxe-visual-layer-separation.md
- docs/decisions/0008-gxe-arrival-to-product-light-bloom-transition.md
