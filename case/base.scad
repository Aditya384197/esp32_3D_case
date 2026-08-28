include <params.scad>

// ---- Layout: components arranged side-by-side along Y on tier 2 ----
esp_y0 = wall;
nrf_y0 = esp_y0 + esp_wid + 4;
tp_y0  = nrf_y0 + nrf_wid + 4;

tier2_z = floor_t + battery_tier_h + standoff_gap;

module outer_shell() {
    rounded_rect(outer_len, outer_wid, corner_r, outer_h);
}

module cavity() {
    translate([wall, wall, floor_t])
        rounded_rect(inner_len, inner_wid, max(corner_r-wall, 0.6), outer_h);
}

module battery_cradle() {
    // half-pipe channel the 18650 rests in, running along X
    cy = wall + cell_d/2 + 1;
    cz = floor_t + cell_d/2 + 1;
    translate([wall, cy, cz])
        rotate([0,90,0])
            cylinder(h=inner_len, d=cell_d + 2*clearance);
    // end-stop ridges so the cell can't roll out lengthwise
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

module tier2_shelf() {
    // thin shelf the upper boards sit on, with a wiring slot to tier 1
    translate([wall, wall, tier2_z - 1.5])
        difference() {
            cube([inner_len, inner_wid, 1.5]);
            translate([inner_len/2 - 6, inner_wid/2 - 4, -0.1])
                cube([12, 8, 1.7]); // wire pass-through slot
        }
}

module board_standoffs(x, y, l, w, standoff_h, hole_d=2.2, boss_d=5.5) {
    inset = 3;
    for (dx = [inset, l-inset])
        for (dy = [inset, w-inset])
            translate([x+dx, y+dy, floor_t + battery_tier_h + standoff_gap - standoff_h])
                difference() {
                    cylinder(h=standoff_h, d=boss_d);
                    translate([0,0,-0.1]) cylinder(h=standoff_h+0.2, d=hole_d);
                }
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
    difference() {
        union() {
            outer_shell();
        }
        cavity();

        // Left wall (X=0): two ESP32-S3 USB-C cutouts, centred on the board's Y-band
        usbc_cutout_x0(esp_y0 + esp_wid/2 - esp_usbc_gap/2, tier2_z + esp_clear_h/2);
        usbc_cutout_x0(esp_y0 + esp_wid/2 + esp_usbc_gap/2, tier2_z + esp_clear_h/2);

        // Left wall (X=0): TP4056 USB-C cutout
        usbc_cutout_x0(tp_y0 + tp_wid/2, tier2_z + tp_h/2 + 1);

        // Right wall (X=outer_len): NRF24L01 SMA antenna hole
        translate([outer_len - wall - 0.1, nrf_y0 + nrf_wid/2, tier2_z + nrf_h/2])
            rotate([0,90,0])
                cylinder(h=wall+0.2, d=sma_hole_d);
    }

    battery_cradle();
    tier2_shelf();
    board_standoffs(wall, esp_y0, esp_len, esp_wid, standoff_gap + 2);
    board_standoffs(wall, nrf_y0, nrf_len, nrf_wid, standoff_gap + 2);
    board_standoffs(wall, tp_y0, tp_len, tp_wid, standoff_gap + 2);
    corner_screw_bosses();
}

base();
