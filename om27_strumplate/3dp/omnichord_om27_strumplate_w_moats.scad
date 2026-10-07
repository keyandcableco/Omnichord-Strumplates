// ============================================================
// Omnichord OM-27 Strumplate Top Plate
// ============================================================
// A cover plate that sits over the flex PCB strum strip.
// Two features create the gap needed between the flex PCB
// contacts and the conductive strumming surface:
//
//   1. MAIN VALLEY  -> a shallow recess: a slim rectangle with small
//      rounded corners at the short ends (NOT a fat pill/stadium),
//      running nearly the FULL length of the plate, independent of
//      where the pad cluster sits, cut to recess_depth.
//   2. PAD RECESS   -> a shallow pocket (same recess_depth) over the
//      small contact pad near the top, connected to a second
//      smaller pocket by a thin bridge slot (matches the two
//      cutouts + connecting tab seen in the reference CAD model).
//
// Both recesses are cut from the TOP face only, leaving a thin,
// paper-thin BOTTOM skin (bottom_skin_thickness) untouched -- that
// skin is the side the user's finger touches, and should be printed
// face-down on the bed as the first layer for max smoothness.
//
// The valley floor also carries a row of raised BUMPS, one per OM-27
// note (12 total), spaced at the note pitch -- these sit on the valley
// floor and rise toward (but stop short of) the top face.
//
// The BOTTOM touch face (z=0) also carries a small engraved MARKER per
// bump (number / dot / dash, selectable) so the player can see which
// "string" each bump corresponds to from the finger side.
//
// Adjust the PARAMETERS block below to match your real
// measurements -- nothing else needs to change.
// ============================================================

/* [Overall plate -- asymmetric trapezoid with a curved top edge] */
// The two LONG edges (left & right) are PARALLEL to each other and are
// the sides the long valley recess runs alongside. The two SHORT edges
// (top & bottom) connect them and are NOT parallel to each other.
// The TOP short edge (opposite the pad cluster, which is mirrored to
// sit near the bottom in the 3D assembly below) is not straight.
edge_left_long   = 159;  // length of the long left edge, mm
edge_right_long  = 142;  // length of the long right edge, mm
edge_top_short   = 63;   // length of the short top edge, mm (straight-line/chord distance
                          // between TL and TR -- the curve deviates from this)
edge_bottom_short = 62;  // length of the short bottom edge, mm (straight)
corner_radius     = 1.5; // small rounding at all four corners (just enough to not be knife-sharp)

// --- Top edge curve: direct, editable point list ---
// Each entry is [t, dev]:
//   t   = position along the TL->TR chord, 0 = TL, 1 = TR
//   dev = perpendicular deviation from the straight chord, in mm
//         (POSITIVE = bulges OUT away from the plate body, NEGATIVE = dips IN)
// The curve is built by linearly interpolating between these points in
// order, so each point's effect is LOCAL -- nudge one [t, dev] pair and
// only the curve segments touching it move, unlike a Bezier where every
// control point affects the whole shape. Add more points for finer
// control anywhere you need it; t doesn't need to be evenly spaced.
// The first point should be [0, 0] (note: this curve doesn't return to
// 0 at t=1 -- it settles at -0.75, which is fine, just means TR sits
// slightly inset from the literal corner; t=1 is still anchored to TR
// in the construction below regardless of the dev value there).
// These points follow your last set (the ones that got close), just
// resampled to a finer 0.05 step using smooth monotone interpolation
// (PCHIP -- passes through your original points exactly, no
// overshoot/ringing introduced in between) so you have more individual
// handles to nudge.
TOP_CURVE_PTS = [
    [0.00, 0.0],
    [0.05, -0.531],
    [0.10, -0.9],
    [0.15, -1.2],
    [0.20, -1.45],
    [0.25, -1.75],
    [0.30, -1.8],
    [0.35, -1.8],
    [0.40, -1.9],
    [0.45, -1.8],
    [0.50, -1.75],
    [0.55, -1.521],
    [0.60, -1.25],
    [0.65, -1.15],
    [0.70, -1],
    [0.75, -1],
    [0.80, -0.9],
    [0.85, -1],
    [0.90, -1],
    [0.95, -1],
    [1.00, -1.25],
];
top_curve_resolution = 6; // segments to interpolate BETWEEN each pair of points
                          // (higher = smoother straight-line approximation of
                          // whatever shape you build with the points above;
                          // since interpolation is linear, this mostly just
                          // affects corner_radius rounding smoothness, not
                          // the underlying shape)

// --- Derived corner geometry (do not edit) ---
// Solve for the perpendicular distance `plate_w` between the two parallel
// long edges, and the vertical stagger `edge_offset` of the right edge
// relative to the left edge, such that the connecting short edges come
// out to edge_top_short / edge_bottom_short exactly (using the straight-
// line/chord length for the top edge, since the S-curve is added after).
// System (derived once and baked in as a closed-form solution):
//   bottom_short^2 = plate_w^2 + edge_offset^2
//   top_short^2    = plate_w^2 + (edge_left_long - (edge_offset + edge_right_long))^2
// Subtracting and solving for edge_offset:
_k = edge_left_long - edge_right_long;
edge_offset = ( (edge_bottom_short*edge_bottom_short) - (edge_top_short*edge_top_short) + (_k*_k) ) / (2*_k);
plate_w = sqrt(edge_bottom_short*edge_bottom_short - edge_offset*edge_offset);

// Corner coordinates (left edge along x=0, right edge along x=plate_w),
// then re-centered so x=0 sits on the long-axis centerline and y=0 sits
// at the vertical midpoint of the left edge, for convenient downstream use.
_BL = [0, 0];
_TL = [0, edge_left_long];
_BR = [plate_w, edge_offset];
_TR = [plate_w, edge_offset + edge_right_long];
_cx = plate_w/2;
_cy = edge_left_long/2;
BL = _BL - [_cx, _cy];
TL = _TL - [_cx, _cy];
BR = _BR - [_cx, _cy];
TR = _TR - [_cx, _cy];

// plate_length kept for backward compatibility with valley/pad placement
// below -- approximate overall span used for "distance from top" offsets.
plate_length = max(TL.y, TR.y) - min(BL.y, BR.y);

// The plate is built from two thicknesses stacked:
//   bottom_skin_thickness -> the touch surface (prints FIRST, face-down on the bed).
//                            Keep this paper-thin (1-2 perimeter layers, e.g. 0.2-0.4mm
//                            at a 0.2mm layer height) so finger contact can reach through
//                            wherever the recess above it is cut.
//   recess_depth           -> how deep the valley/pad recesses cut into the TOP face.
// plate_thickness is just their sum -- change the two thickness values, not this one.
bottom_skin_thickness = 0.45;   // <-- paper-thin touch surface, tune to your layer height
recess_depth          = 0.75;   // depth of the valley + pad recesses, cut from the top
plate_thickness        = bottom_skin_thickness + recess_depth;

/* [Main valley - shallow recess, sized to the OM-84 flex PCB contact row] */
// Measured from the OM-84 strumplate_traces.svg: 13 contacts, pitch
// 11.275mm center-to-center, each contact finger 13.698mm long (the
// across-strip dimension) x 4.421mm wide (the along-strip dimension).
contact_pitch       = 11.275; // mm, center-to-center spacing along the strip
contact_count       = 13;     // number of contacts in the row
valley_width      = 21;   // matches the OM-84 contact finger length (across-strip)
valley_length     = contact_pitch * (contact_count - 1) + 10; // total span of the row, ~139.7mm
valley_margin_top    = 8;  // gap kept between the top-left corner and the start of the valley
                             // (only used to help VERTICALLY CENTER the now fixed-length valley;
                             // see valley_2d() below)
valley_inset      = valley_width/2+8;    // how far in from the LEFT edge the recess sits, mm
valley_end_radius = 3;    // corner rounding radius at the two short ends (small radius,
                           // NOT half the width -- gives slim rounded-rect ends like the
                           // metallic strip in the reference photo, not a full pill cap)

/* [Valley bumps - one per OM-27 note] */
// The OM-27 has 12 notes/contacts. These bumps sit on the valley floor
// and are distributed evenly along the valley's long axis at the note
// pitch. They rise off the floor but stop short of the top face so the
// contacts stay separated.
om27_note_count   = 12;    // number of notes/contacts on the OM-27
// span used to distribute the bumps = the valley length minus the
// rounded end caps and a small margin, so bumps stay off the curved ends
bump_span         = valley_length - 2*valley_end_radius - 6;
bump_pitch        = bump_span / (om27_note_count - 1); // center-to-center along strip
                                                        // (replace with your measured OM-27
                                                        // note pitch if you have it)
bump_width        = valley_width - 2;  // across-strip size (slightly inset from valley walls)
bump_length       = 7;   // along-strip size of each bump
bump_corner_r     = 1.0;   // rounding of each bump rectangle
bump_height       = recess_depth - 0.5; // how far the bump rises off the valley floor
                                          // (stays below the top face by 0.25mm)

/* [Button living hinge - a thinned moat around each bump] */
// Each bump acts as a "button" over a flex-PCB contact. To let each
// button deflect DOWNWARD on its own (instead of the whole skin flexing
// as one sheet), a ring-shaped groove ("moat") is cut from the TOP
// (valley floor) side around each bump. The skin under the moat is
// thinned to hinge_thickness, forming a compliant living-hinge membrane
// that isolates each button island while keeping the z=0 touch face
// perfectly smooth (nothing is cut from the finger side).
hinge_on          = true;  // master toggle for the button moats
hinge_thickness   = 0.25;  // skin thickness remaining UNDER the moat, mm.
                            // Thinner = more pliable but weaker / more fragile.
                            // MUST be < bottom_skin_thickness (0.45).
moat_width        = 0.55;   // radial width of the thinned ring around each bump, mm.
                            // Wider = softer/longer hinge travel.
moat_gap          = 0.4;   // small gap between the bump wall and the INNER edge
                            // of the moat, so the moat doesn't undercut the bump
                            // base (keeps the button island's full-thickness
                            // footprint slightly larger than the bump itself).
// derived: how deep the moat cuts below the valley floor to leave hinge_thickness
moat_depth        = bottom_skin_thickness - hinge_thickness;

/* [String markers - engraved into the z=0 touch face, one per bump] */
// Small indicator engraved into the BOTTOM (finger) face, one aligned to
// each bump, so the player can tell which "string" is which from the
// touch side. Engraved (recessed) into z=0, offset toward -X (left edge)
// relative to each bump's center.
marker_style       = "dot"; // "number" -> 1..N digits (uses text(), slower render)
                                 // "dot"    -> a small round dot
                                 // "dash"   -> a short line/dash
                                 // "none"   -> disable markers entirely
marker_depth       = 0.15;   // how deep the marker is engraved into z=0, mm.
                             // MUST stay < bottom_skin_thickness (0.45) or it
                             // punches through the touch skin.
marker_offset_x    = 0;     // offset of each marker from its bump CENTER along
                             // X. 0 = centered directly over the bump.
                             // POSITIVE = nudge toward +X long edge,
                             // NEGATIVE = nudge toward -X long edge.
                             // (e.g. +3 = centered but pushed slightly toward
                             // the +X long side.)
marker_flip_180    = true;  // true  -> each digit is rotated 180 deg AND the
                             //          numbering runs from the opposite short
                             //          end (so "1" starts at the far end).
                             // false -> digits upright, "1" at the near end.
                             // This no longer moves markers sideways -- use
                             // marker_offset_x for that.
// -- number style --
marker_text_size   = 5;     // font height for digits, mm
marker_font        = "Liberation Sans:style=Bold";
marker_number_from = 1;     // first string's number (1 -> strings labeled 1..N)
// -- dot style --
marker_dot_r       = 1.6;   // dot radius, mm
// -- dash style --
marker_dash_len    = 5;     // dash length along X, mm
marker_dash_wid    = 1.4;   // dash thickness along Y, mm

/* [Octave markers - a ring around every Nth marker] */
// Highlight octaves by drawing a ring around selected markers. By default
// every 3rd marker (the 1st, 4th, 7th, ...) gets a ring.
octave_ring_on     = true;  // master toggle for the octave rings
octave_interval    = 3;     // ring every Nth marker (3 -> 1st, 4th, 7th, ...)
octave_phase       = 0;     // shift which marker is first ringed. 0 = ring the
                             // 1st marker. 1 = start at the 2nd, etc. Counted in
                             // the SAME order as the printed numbers, so the ring
                             // follows "1, 4, 7..." regardless of marker_flip_180.
octave_ring_r      = 4.2;   // outer radius of the ring (should clear the digit;
                             // ~ marker_text_size*0.8 is a good starting point)
octave_ring_thick  = 0.8;   // wall thickness of the ring, mm
                             // (inner radius = octave_ring_r - octave_ring_thick)

/* [Pad recess cluster - sized to the OM-84 flex PCB pad contacts] */
// Measured from the same SVG: pad pitch 14.97mm center-to-center.
pad_contact_pitch = 14.97;  // mm, center-to-center spacing between the two pads
pad1_w = 13; pad1_h = 13;   // upper pad rectangle (rounded)
pad2_w = 13; pad2_h = 13;   // lower pad rectangle (rounded)
pad_corner_r       = 1.2;   // corner rounding for the pad rectangles
pad_gap            = pad_contact_pitch - pad1_h/2 - pad2_h/2; // vertical gap between pad1/pad2, derived from pitch
tab_width          = 2.5;   // width of the connecting bridge slot between pad1/pad2
min_wall_to_valley = 4;     // (unused now that spacing is set directly by distance below;
                             // kept only for reference/back-compat)
pad_to_valley_center_dist = 35; // distance between pad-cluster center and valley center, mm

// Final layout: the VALLEY sits on the NEGATIVE X side (toward the
// left edge) and stays exactly where it was. The PAD CLUSTER's center
// is placed exactly pad_to_valley_center_dist (35mm) away from the
// valley's center, along X.
pad_cluster_half_w = max(pad1_w, pad2_w) / 2;
valley_x_center = BL.x + valley_inset;
pad_offset_x = valley_x_center + pad_to_valley_center_dist;
pad_offset_y_top = TL.y - 25 + 13;   // y position where pad1 (upper) starts, measured down from top-left corner

/* [Rendering] */
$fn = 60;

// ============================================================
// 2D PROFILES
// ============================================================

// Asymmetric trapezoid plate outline: long left edge and long right
// edge are parallel; short bottom edge is straight; short TOP edge
// follows TOP_CURVE_PTS (see PARAMETERS above), projected onto the
// real TL-TR chord and linearly interpolated point-to-point, built
// from the solved corner points BL/TL/BR/TR, with small corner
// rounding applied at the end.
module plate_solid_2d() {
    chord = TR - TL;
    chord_len = norm(chord);
    u = chord / chord_len;
    perp = [u.y, -u.x];
    plate_center_dir = ((BL + BR) / 2) - (TL + TR) / 2;
    // outward_dir points AWAY from the plate body (so + dev bulges out)
    outward_dir = (perp.x*plate_center_dir.x + perp.y*plate_center_dir.y > 0) ? -perp : perp;

    // project each [t, dev] point onto the real chord
    anchor_pts = [
        for (pair = TOP_CURVE_PTS)
            TL + pair[0]*chord + outward_dir*pair[1]
    ];

    // linearly interpolate top_curve_resolution extra points between each
    // consecutive pair of anchors, so corner_radius rounding (which acts
    // on every vertex) has more, closer-together points to round smoothly
    // rather than just the handful of anchors themselves
    n_anchors = len(anchor_pts);
    top_curve_TL_to_TR = [
        for (seg = [0 : n_anchors - 2])
            for (k = [0 : top_curve_resolution - 1])
                let(
                    a = anchor_pts[seg],
                    b = anchor_pts[seg + 1],
                    f = k / top_curve_resolution
                )
                a + (b - a) * f
    ];
    top_curve_TL_to_TR_full = concat(top_curve_TL_to_TR, [anchor_pts[n_anchors - 1]]);
    top_curve_pts = [for (i = [len(top_curve_TL_to_TR_full)-1:-1:0]) top_curve_TL_to_TR_full[i]]; // TR -> ... -> TL

    offset(r = corner_radius)
        offset(delta = -corner_radius)
            polygon(points = concat([BL, BR], top_curve_pts));
}

// Single rounded rectangle helper (centered)
module rounded_rect(w, h, r) {
    hull() {
        translate([ w/2 - r,  h/2 - r]) circle(r = r);
        translate([-w/2 + r,  h/2 - r]) circle(r = r);
        translate([ w/2 - r, -h/2 + r]) circle(r = r);
        translate([-w/2 + r, -h/2 + r]) circle(r = r);
    }
}

// Main valley: long slim rectangle with small rounded corners at the
// short ends, sized to exactly span the OM-84 contact row (fixed
// valley_length, see PARAMETERS), inset in from the left edge.
module valley_2d() {
    y_top = TL.y - valley_margin_top;
    y_center = y_top - valley_length/2;

    translate([valley_x_center, y_center])
        rounded_rect(valley_width, valley_length, valley_end_radius);
}

// Y-position of bump i's center (shared by the bumps and the markers so
// they always stay aligned).
function bump_cy(i) =
    let(
        y_top    = TL.y - valley_margin_top,
        y_center = y_top - valley_length/2,
        y_start  = y_center + bump_span/2
    )
    y_start - i*bump_pitch;

// Valley bumps: one rounded bump per OM-27 note, distributed evenly
// along the valley's long axis, centered across the valley width.
module valley_bumps_2d() {
    for (i = [0 : om27_note_count - 1]) {
        translate([valley_x_center, bump_cy(i)])
            rounded_rect(bump_width, bump_length, bump_corner_r);
    }
}

// One bump's rounded-rect outline, centered at origin (helper so the moat
// can be built by offsetting the exact bump footprint).
module bump_outline_2d() {
    rounded_rect(bump_width, bump_length, bump_corner_r);
}

// Living-hinge moats: an annular (ring) groove around each bump. The
// annulus outer edge = bump outline grown by (moat_gap + moat_width);
// inner edge = bump outline grown by moat_gap. Cutting this ring down
// from the valley floor thins the skin to hinge_thickness there, so each
// button island can flex downward independently.
module button_moats_2d() {
    for (i = [0 : om27_note_count - 1]) {
        translate([valley_x_center, bump_cy(i)])
            difference() {
                offset(r = moat_gap + moat_width) bump_outline_2d();
                offset(r = moat_gap)              bump_outline_2d();
            }
    }
}

// A single marker's 2D shape, centered at origin, per marker_style.
// `idx` is the zero-based bump index (used only for numbering).
module marker_shape_2d(idx) {
    // the glyph/dot/dash itself
    if (marker_style == "number") {
        // mirror([1,0,0]) makes the digit read correctly when the part is
        // flipped to its finger side (done per-glyph, about its own center,
        // so marker positions are unaffected). The rotate() then applies
        // the requested 180 deg flip when marker_flip_180 is set.
        rotate(marker_flip_180 ? 180 : 0)
        mirror([1, 0, 0])
        text(
            str(number_for_index(idx)),
            size = marker_text_size,
            font = marker_font,
            halign = "center",
            valign = "center"
        );
    } else if (marker_style == "dot") {
        circle(r = marker_dot_r);
    } else if (marker_style == "dash") {
        square([marker_dash_len, marker_dash_wid], center = true);
    }
    // "none" -> nothing

    // octave ring around this marker, if it lands on an octave
    if (octave_ring_on && is_octave_marker(idx))
        octave_ring_2d();
}

// A thin ring (annulus), centered at origin, engraved along with the
// marker to flag an octave.
module octave_ring_2d() {
    difference() {
        circle(r = octave_ring_r);
        circle(r = octave_ring_r - octave_ring_thick);
    }
}

// True if the marker at bump index `idx` should get an octave ring.
// Keyed to the PRINTED number (via number_for_index) so the ring always
// follows "1, 1+interval, 1+2*interval, ..." counting from marker_number_from,
// regardless of marker_flip_180. octave_phase shifts the starting marker.
function is_octave_marker(idx) =
    let(n = number_for_index(idx) - marker_number_from - octave_phase)
    (n >= 0) && (n % octave_interval == 0);

// Which printed number a given bump index gets. When flipped, the
// sequence runs from the opposite short end so "1" starts at the far end.
function number_for_index(idx) =
    marker_flip_180
        ? marker_number_from + (om27_note_count - 1 - idx)
        : marker_number_from + idx;

// All markers, laid out in 2D. Each marker is centered on its bump's
// (X,Y) and shifted along X by marker_offset_x only:
//   marker_offset_x = 0  -> directly centered over the bump
//   marker_offset_x > 0  -> nudged toward the +X long edge
//   marker_offset_x < 0  -> nudged toward the -X long edge
// NOTE: drawn in the plate's own (unmirrored) XY frame; the engraving in
// the 3D assembly flips it into the z=0 face so it reads correctly from
// the finger side. Numbering direction and per-digit 180 deg rotation are
// handled via marker_flip_180 (see number_for_index / marker_shape_2d).
module markers_2d() {
    if (marker_style != "none") {
        for (i = [0 : om27_note_count - 1]) {
            translate([valley_x_center + marker_offset_x, bump_cy(i)])
                marker_shape_2d(i);
        }
    }
}

// Pad recess cluster: pad1 (upper) + pad2 (lower) + connecting bridge tab
module pad_cluster_2d() {
    pad1_cy = pad_offset_y_top - pad1_h/2;
    pad2_cy = pad1_cy - pad1_h/2 - pad_gap - pad2_h/2;

    union() {
        translate([pad_offset_x, pad1_cy])
            rounded_rect(pad1_w, pad1_h, pad_corner_r);

        translate([pad_offset_x, pad2_cy])
            rounded_rect(pad2_w, pad2_h, pad_corner_r);

        // connecting bridge between the two pads
        translate([pad_offset_x, (pad1_cy + pad2_cy)/2])
            square([tab_width, pad1_h/2 + pad_gap + pad2_h/2], center = true);
    }
}

// ============================================================
// 3D ASSEMBLY
// ============================================================
// Orientation: z=0 is the BOTTOM touch surface (this should be
// the face that sits on the print bed, i.e. print this part
// face-down / recesses-up so the smooth first layer becomes the
// finger-touch side). z = plate_thickness is the TOP face where
// both recesses are cut in.

module strumplate() {
    difference() {
        // base plate
        linear_extrude(height = plate_thickness)
            plate_solid_2d();

        // 1) main valley -- shallow recess cut from the TOP face only,
        //    leaving bottom_skin_thickness of solid material below it
        translate([0, 0, bottom_skin_thickness])
            linear_extrude(height = recess_depth + 0.5)
                valley_2d();

        // 2) pad recess -- shallow pocket cut from the TOP face only,
        //    same depth, same remaining bottom skin
        translate([0, 0, bottom_skin_thickness])
        mirror([0,1,0])
            linear_extrude(height = recess_depth + 0.5)
                pad_cluster_2d();

        // 3) string markers -- engraved into the z=0 touch face, one per
        //    bump. Cut UP from just below z=0 to marker_depth so it
        //    recesses into the bottom skin only. Each glyph is mirrored
        //    about its own center (inside marker_shape_2d) so the numbers
        //    read correctly when the part is flipped to its finger side --
        //    positions are NOT mirrored, so markers stay on the valley.
        translate([0, 0, -0.01])
            linear_extrude(height = marker_depth + 0.01)
                markers_2d();

        // 4) living-hinge moats -- ring grooves cut DOWN into the valley
        //    floor around each bump, thinning the skin there to
        //    hinge_thickness so each button island can deflect downward on
        //    its own. Cut from z=hinge_thickness up past the floor so the
        //    groove opens into the valley recess above. Nothing is removed
        //    from the z=0 touch face, which stays smooth.
        if (hinge_on)
            translate([0, 0, hinge_thickness])
                linear_extrude(height = moat_depth + recess_depth + 0.5)
                    button_moats_2d();
    }

    // 4) valley bumps -- raised nubs on the valley floor, one per OM-27
    //    note, rising from the floor (at bottom_skin_thickness) but
    //    stopping short of the top face by (recess_depth - bump_height)
    translate([0, 0, bottom_skin_thickness])
        linear_extrude(height = bump_height)
            valley_bumps_2d();
}

strumplate();

// ------------------------------------------------------------
// Uncomment to sanity-check the 2D layout from directly above
// before committing to the 3D print:
// projection(cut = false) strumplate();
