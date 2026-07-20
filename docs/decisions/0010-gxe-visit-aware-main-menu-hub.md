# ADR 0010: GXE Visit-Aware Main Menu Hub

Status: Accepted
Date: 2026-06-30

## Context
GXE is growing from a single cinematic product reveal into a small branded site
with one or two additional destinations. Replaying the complete press-and-hold
ritual and product film on every visit would make the experience feel repetitive,
while a conventional homepage and navigation bar would weaken its world-like,
game-menu character.

The current podium destination also treats the product film as the final page.
The new direction needs the film to introduce a persistent Main Menu that can
display the featured piece, provide access to the rest of GXE, and later support
focused product inspection.

## Decision
The GXE Main Menu will become the primary hub and the destination that connects
the site's small number of sections.

First-time flow:

```text
press-and-hold GXE ritual
full-frame bloom
approximately six-second full-screen product film
brief final-frame hold
subtle perspective pullback/reframe
Main Menu
```

The final frame of the product film should become the visual starting point for
the Main Menu transition where practical. The view backs away to reveal context
around the product rather than cutting to an unrelated shopping layout.

Returning flow on the same browser:

```text
short automatic GXE loading animation
brief light-bloom handoff
Main Menu
```

Returning visitors skip the press-and-hold ritual and product film. Completion
may be remembered with simple local browser storage; it does not require an
account or server-side identity. The Main Menu should offer a restrained way to
replay the complete introduction.

The Main Menu may borrow the useful interaction language of a premium video-game
lobby without presenting GXE as a game or copying a specific game's interface:

- The featured piece occupies the dominant central display area, with a possible
  slight upper-left bias if that improves the composition.
- A clear primary action such as `Explore piece` or `Shop now` sits in the
  lower-right action area.
- A small top section bar shows the current location through a clear highlight.
- Selecting an adjacent section feels like moving horizontally to the next or
  previous menu space.
- The small section list may wrap cyclically from its last item back to Main Menu
  and from Main Menu back to the last item.
- Mobile may support restrained horizontal swiping in addition to direct tab
  selection, but every destination must remain operable without a swipe.
- The top section bar is part of the Main Menu shell and may remain visible while
  moving among its one or two additional section spaces. It should feel like one
  hub rotating through destinations, not a conventional site-wide navbar.
- Browser Back and direct page access must remain understandable and functional;
  the hub model should not trap the visitor.

Selecting the featured piece opens a focused inspection mode. The product expands
to fill the experience while surrounding menu elements recede, leaving only the
visitor and the piece. The visitor may manipulate the product only to the degree
supported by the available asset, such as dragging, panning, or zooming a strong
2D image. Clicking or tapping outside the inspection area, using a visible back
control, or pressing Escape returns to the Main Menu.

True 360-degree rotation, 3D garment rendering, and invented views of the product
are not V1 requirements. Those behaviors require appropriate client assets and
should not be simulated poorly.

The Main Menu's exact visual composition, final section names, product scale,
background treatment, and navigation spacing remain open until a sketch is
reviewed. This ADR defines the experience structure, not the final art direction.

## Why
The first visit remains memorable because the visitor earns entry through GXE's
jewelry reveal. Returning visits become faster and more respectful while still
receiving a short branded handoff.

A Main Menu provides one clear home for the featured product and future pages
without turning GXE into a conventional scrolling storefront. The lobby model
also supports the client's desire for attention, presentation, and a strong
central object while keeping the number of choices small.

Reframing the final product-film frame into the menu preserves continuity. The
film, menu, and shopping path feel like parts of one experience rather than three
separate pages.

## Alternatives Considered
Replay the complete intro on every visit:

- Preserves the full ceremony.
- Becomes repetitive and delays returning visitors from reaching the site.

End directly on a conventional product page:

- Familiar and easy to implement.
- Gives GXE no central world or navigation hub and weakens the cinematic entry.

Require another interaction after the product film:

- Gives the visitor control over when to proceed.
- Adds unnecessary friction after the visitor already completed the entry ritual.

Build true 3D product inspection immediately:

- Could create a richer object experience.
- Requires better assets and considerably more complexity than the current V1
  can justify.

## Consequences
ADR 0009 remains the source of truth for the first-visit press-and-hold ice-out
ritual. This ADR amends its destination: the product film now leads into the Main
Menu instead of ending as the final podium product page.

The implementation will need a small visit-state decision, a short returning-user
loader, a film-to-menu transition, and a finite set of menu and inspection states.
These should remain inside the isolated GXE theme until the pattern proves useful
elsewhere.

The six-second product-film treatment and first Main Menu landing shell are now
implemented. The current shell keeps the featured piece dominant, introduces its
supporting information during the film, and uses an intentionally unwired
`Reserve Piece` action. Visit memory, the short returning-user loader, cyclic
section navigation, and focused product inspection remain approved but deferred.

The menu must remain restrained. Game-menu inspiration should provide hierarchy,
orientation, and satisfying transitions without introducing fake game language,
dense HUD elements, currencies, progression systems, or unnecessary effects.

Local visit memory is device- and browser-specific. Clearing site data or using a
different browser will restore the first-time flow. A replay option is therefore
valuable for testing and for visitors who want to see the ritual again.

## Related Files
- templates/gxe/layout.html
- templates/gxe/assets/style.css
- templates/gxe/assets/experience.js
- templates/gxe/assets/gxe-product.mp4
- content/profiles/gxe.json
- docs/CURRENT_WORK.md
- docs/decisions/0009-gxe-press-and-hold-ice-out-transition.md
