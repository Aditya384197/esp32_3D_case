include <params.scad>

module lid_screw_holes() {
    inset = corner_r + 3;
    positions = [
        [inset, inset],
        [outer_len-inset, inset],
        [inset, outer_wid-inset],
        [outer_len-inset, outer_wid-inset]
    ];
    for (p = positions)
        translate([p[0], p[1], -0.1])
            cylinder(h=lid_t+0.2, d=3.2);
}

module oled_window() {
    cx = outer_len * 0.32;
    cy = outer_wid / 2;
    translate([cx - oled_win_w/2, cy - oled_win_h/2, -0.1])
        cube([oled_win_w, oled_win_h, lid_t+0.2]);
}

module oled_standoffs() {
    cx = outer_len * 0.32;
    cy = outer_wid / 2;
    half = oled_hole_span/2;
    for (dx = [-half, half])
        for (dy = [-half, half])
            translate([cx+dx, cy+dy, -6])
                difference() {
                    cylinder(h=6, d=oled_standoff_d+3);
                    translate([0,0,-0.1]) cylinder(h=6.2, d=2.0);
                }
}

module dpad_buttons() {
    cx = outer_len * 0.72;
    cy = outer_wid / 2;
    step = 11;
    positions = [
        [cx, cy+step],       // up
        [cx, cy-step],       // down
        [cx-step, cy],       // left
        [cx+step, cy],       // right
        [cx, cy]             // centre / select
    ];
    for (p = positions)
        translate([p[0], p[1], -0.1])
            cylinder(h=lid_t+0.2, d=btn_hole_d);
}

module led_hole() {
    cx = outer_len * 0.72;
    cy = outer_wid * 0.86;
    translate([cx, cy, -0.1])
        cylinder(h=lid_t+0.2, d=led_hole_d);
}

module lid() {
    difference() {
        rounded_rect(outer_len, outer_wid, corner_r, lid_t);
        lid_screw_holes();
        oled_window();
        dpad_buttons();
        led_hole();
    }
    oled_standoffs();
}

lid();
