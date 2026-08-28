// ============================================================
// Parametric ESP32-S3 Node Enclosure — shared dimensions
// All values in millimetres. Sourced from published module
// datasheets/listings (see README.md for sources). Verify
// against your own physical parts before printing.
// ============================================================

$fn = 48;

// ---- Print-friendly wall thicknesses (kept thin to save weight/cost) ----
wall        = 1.8;
floor_t     = 1.8;
lid_t       = 1.8;
clearance   = 0.35;   // general fit clearance added around components
corner_r    = 3;      // outer corner rounding radius

// ---- ESP32-S3 dual USB-C dev board ----
// Board: ~63.5 x 28 mm, module end ~57.1 mm long (Waveshare/dual-C clones)
esp_len     = 63.5;
esp_wid     = 28.0;
esp_clear_h = 10.0;   // clearance above board for USB-C plugs / antenna trace
esp_usbc_w  = 9.0;    // USB-C shell cutout width
esp_usbc_h  = 3.6;    // USB-C shell cutout height
esp_usbc_gap= 20.0;   // centre-to-centre spacing between the two USB-C ports

// ---- NRF24L01+PA+LNA (large body, SMA antenna) ----
// Board: 40.7 x 15.5 x 12.2 mm (Addicore/SainSmart/MakerFocus agree)
nrf_len     = 40.7;
nrf_wid     = 15.5;
nrf_h       = 12.2;
sma_hole_d  = 10.5;   // SMA bulkhead through-hole (nut across-flats ~10mm)

// ---- TP4056 Type-C charge/protection module ----
// Board: ~27 x 17.5 x 5 mm (rounded up from 25-29 x 17-20mm listings)
tp_len      = 27.0;
tp_wid      = 17.5;
tp_h        = 5.0;
tp_usbc_w   = 9.0;
tp_usbc_h   = 3.6;

// ---- 18650 Li-ion cell ----
cell_d      = 18.6;
cell_len    = 65.2;

// ---- 0.96" OLED, 128x64, SSD1306 ----
oled_pcb    = 27.3;   // square PCB
oled_win_w  = 24.0;   // visible-window cutout in the lid
oled_win_h  = 13.5;
oled_hole_span = 23.5; // corner mounting-hole spacing (typical on this PCB)
oled_standoff_d = 3.4;

// ---- 5mm indicator LED ----
led_hole_d  = 3.2;

// ---- Tactile push buttons (generic 6x6mm through-hole) ----
btn_hole_d  = 3.6;    // clears the round actuator, keeps the shoulder outside
btn_body    = 6.0;

// ---- Antenna passthrough (whip antenna with ~10mm SMA base) ----
antenna_hole_d = 10.5;

// ---- Derived internal cavity ----
// Tier 2 (upper shelf) holds ESP32-S3 + NRF24L01 + TP4056 side by side
tier2_w = esp_wid + nrf_wid + tp_wid + 3*4;              // + gaps between boards
tier2_l = my_max(esp_len, cell_len + 4);

inner_len = tier2_l + 4;
inner_wid = tier2_w + 4;

battery_tier_h = cell_d + 3;      // cradle + clearance
standoff_gap   = 3;               // air gap between tiers for wiring
tier2_h        = nrf_h + clearance + 2; // tallest tier-2 part

inner_h = battery_tier_h + standoff_gap + tier2_h;

outer_len = inner_len + 2*wall;
outer_wid = inner_wid + 2*wall;
outer_h   = inner_h + floor_t + lid_t;

function my_max(a,b) = a > b ? a : b;

// ---- Rounded rectangle helper (hull of 4 corner cylinders) ----
module rounded_rect(l, w, r, h) {
    hull() {
        for (x = [r, l-r])
            for (y = [r, w-r])
                translate([x, y, 0])
                    cylinder(h=h, r=r);
    }
}

module screw_boss(od=7, id=2.6, h=8) {
    difference() {
        cylinder(h=h, d=od);
        translate([0,0,-0.1]) cylinder(h=h+0.2, d=id);
    }
}
