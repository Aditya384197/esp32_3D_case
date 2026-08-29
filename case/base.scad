include <params.scad>

// ============================================================
// Tier-2 board layout: built as a list so it automatically
// adapts to nrf_count. Each entry: [name, y0, length, width, height]
// ============================================================
function board_list() =
    let(y0_esp = wall)
    let(y0_nrf0 = y0_esp + esp_wid + board_gap)
    [
        ["esp", y0_esp, esp_len, esp_wid, esp_clear_h],
        for (i = [0 : nrf_count-1])
            ["nrf", y0_nrf0 + i*(nrf_wid + board_gap), nrf_len, nrf_wid, nrf_h],
        ["tp",  y0_nrf0 + nrf_count*(nrf_wid + board_gap), tp_len, tp_wid, tp_h]
    ];

boards = board_list();

tier2_z = floor_t + battery_tier_h + standoff_gap;

module outer_shell() {
    rounded_rect(outer_len, outer_wid, corner_r, outer_h);
}

module cavity() {
    // cuts fully through from just above the floor to well past the
    // open top -- the interior is a single open tub, nothing blocks it
    translate([wall, wall, floor_t])
        rounded_rect(inner_len, inner_wid, my_max(corner_r-wall, 0.6), outer_h);
}

module battery_cradle() {
    cy = wall + cell_d/2 + 1;
    cz = floor_t + cell_d/2 + 1;
    translate([wall, cy, cz])
        rotate([0,90,0])
            cylinder(h=inner_len, d=cell_d + 2*clearance);
    translate([wall - 0.1, cy, cz])
        rotate([0,90,0])
            difference() {
                cylinder(h=2, d=cell_d + 6);
                cylinder(h=2, d=cell_d + 2*clearance);
            }
    translate([wall + inner_len - 2, cy, cz])
        rotate([0,90,0])
            difference() {
                cylinder(h=2, d=cell_d + 6);
                cylinder(h=2, d=cell_d + 2*clearance);
            }
}

// 4 corner support/screw posts under one board footprint.
// Posts only -- nothing spans between them, so the space below
// and around every board stays completely open.
module board_standoffs(y0, l, w, standoff_h, hole_d=2.2, boss_d=5.5) {
    inset = 3;
    for (dx = [inset, l-inset])
        for (dy = [inset, w-inset])
            translate([wall+dx, y0+dy, tier2_z - standoff_h])
                difference() {
                    cylinder(h=standoff_h, d=boss_d);
                    translate([0,0,-0.1]) cylinder(h=standoff_h+0.2, d=hole_d);
                }
}

// Low guide ribs hugging the board's footprint so it can't slide
// sideways or slip back out through the connector wall once dropped
// in from the open top. Ribs are short (2.2mm) -- well under any
// board's standoff height -- so they never lift the board off its
// posts. No rib is placed at the connector-facing (X=wall) edge, so
// the USB-C cutouts there stay fully clear.
module board_guides(y0, l, w) {
    rib = 1.6;
    rib_h = 2.2;
    translate([wall - rib, y0 - rib, tier2_z])
        cube([l + 2*rib, rib, rib_h]);          // near-side rail (Y guide)
    translate([wall - rib, y0 + w, tier2_z])
        cube([l + 2*rib, rib, rib_h]);           // far-side rail (Y guide, opposite edge)
    translate([wall + l, y0 - rib, tier2_z])
        cube([rib, w + 2*rib, rib_h]);           // far-end rail (X guide, away from connectors)
}

module usbc_cutout_x0(y_centre, z_centre) {
    translate([-0.1, y_centre - esp_usbc_w/2, z_centre - esp_usbc_h/2])
        cube([wall + 0.2, esp_usbc_w, esp_usbc_h]);
}

module corner_screw_bosses() {
    inset = corner_r + 3;
    positions = [
        [inset, inset],
        [outer_len-inset, inset],
        [inset, outer_wid-inset],
        [outer_len-inset, outer_wid-inset]
    ];
    for (p = positions)
        translate([p[0], p[1], floor_t])
            screw_boss(od=7, id=2.6, h=outer_h - floor_t - 1.5);
}

module base() {
    esp_b = boards[0];
    tp_b  = boards[len(boards)-1];

    difference() {
        outer_shell();
        cavity();

        // Left wall (X=0): two ESP32-S3 USB-C cutouts, centred on its band
        usbc_cutout_x0(esp_b[1] + esp_b[3]/2 - esp_usbc_gap/2, tier2_z + esp_clear_h/2);
        usbc_cutout_x0(esp_b[1] + esp_b[3]/2 + esp_usbc_gap/2, tier2_z + esp_clear_h/2);

        // Left wall (X=0): TP4056 USB-C cutout
        usbc_cutout_x0(tp_b[1] + tp_b[3]/2, tier2_z + tp_h/2 + 1);

        // Right wall (X=outer_len): one SMA antenna hole per NRF24 module
        for (i = [0 : nrf_count-1]) {
            b = boards[1+i];
            translate([outer_len - wall - 0.1, b[1] + b[3]/2, tier2_z + nrf_h/2])
                rotate([0,90,0])
                    cylinder(h=wall+0.2, d=sma_hole_d);
        }
    }

    battery_cradle();
    corner_screw_bosses();

    for (b = boards) {
        board_standoffs(b[1], b[2], b[3], standoff_gap + 2);
        board_guides(b[1], b[2], b[3]);
    }
}

base();
