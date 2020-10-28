//(c) Inne Lemstra 05-10-20

//v0
//prototype version of the soft soldering jig.
//It has a minimal area to test the basic principle.

//mold consist of 2 parts.

$fn = 50;



render_model = true;
         render_cross_section = true;
         angle_cross_section = 90;
render_mold = false;
render_drain_plug = false;


dia_city = 90;
w_city_wall = 2;


//buillding
w_building = 10;
l_building =  w_building;   //buildings are square
h_building = 3;

w_street = .8;


dia_pothole = 1.2;    // 1206 LED is 3.2mm by 1.6 mm
h_pothole_pipe = 0.5; //transision cone between pothole and pipe
dia_plaza = dia_pothole * 6 ;
h_above_ground = h_building;


h_underground = 10;
dia_drain = 5;
dia_pipe  = 1;

//mold variables
dia_hand = 90;
h_rod_handle = 10;
w_mold_wall = 3;
h_mold_wall = h_underground + h_building + w_mold_wall;

h_top_handle_plate = 2;



nx_buildings = 2;      //number of buildings in x direction
ny_buildings = 2 ;    //number of buildings in y direction

l_grid = (l_building + w_street) * nx_buildings - w_street; //grid of buildings
w_grid = (w_building + w_street) * nx_buildings - w_street; 

module make_grid(allow_outside_city = true, w_boundries = [0,0]){
        
    union(){
        for(i = [0:1:nx_buildings - 1]){
            for(j = [0:1:nx_buildings - 1]){
                
                //pythogoras incoming
                if(allow_outside_city || (
                    pow(l_grid / 2 - ((l_building +w_street) * i ), 2) + 
                        pow(w_boundries[0], 2) +
                    pow(( w_grid / 2 - ((w_building +w_street)*j )), 2) +
                        pow(w_boundries[1] , 2)
                    < pow(dia_city / 2 , 2))
                ){
                translate([(l_building +w_street) * i, (w_building +w_street)*j,0])
                //translate([0,0, h_building /2])     //at origin but above z plane
                children();
                    }
                
            }
        }
    }
}

module grid_to_origin() translate([l_grid / -2, w_grid / -2, 0]) children();


module make_model(){
    //make just 1 block (of houses)
    difference(){
        grid_to_origin() make_grid()cube([l_building, w_building, h_building]);
        cylinder(h_building, d=dia_plaza);
    }
    
    //make_onderground
    rotate([180,0,0])
    difference(){
        cylinder(h_underground, d= w_grid + 10);
        cylinder(h_underground /2, d= dia_pothole);
        translate([0, 0, h_underground / 2])
        rotate([-90,0, 0])
        cylinder(h = w_building + w_street /2, d2= dia_drain, d1 = dia_pipe );
        translate([0,  w_building + w_street /2 - 2, h_underground / 2])
        rotate([-90,0, 0])
        cylinder(h = 12, d= dia_drain);
        translate([0,0, h_underground / 2])
        sphere(d= dia_pothole);
    }
}

if(render_model){
   difference(){
    make_model();
     if( render_cross_section) area_cross_section(angle_cross_section);
     }
}

w_mold = w_grid + 10 + w_mold_wall;
h_mold = h_underground + h_building+ w_mold_wall;
l_tube = 2+5;

if(render_mold){
    difference(){
    translate([0,0, - h_underground ])
    cylinder(h_mold, d= w_grid + 10 + w_mold_wall);
    make_model();
     prototype_drain();
    
    }

}

module prototype_drain(){
    rotate([180,0,0]){
            translate([0, 0, h_underground / 2])
        rotate([-90,0, 0])
        cylinder(h = w_building + w_street /2, d2= dia_drain, d1 = dia_pipe );
        translate([0,  w_building + w_street /2 - 2, h_underground / 2])
        rotate([-90,0, 0])
        cylinder(h = l_tube +w_mold_wall, d= dia_drain);
    }

}

module drain_plug(){
        //making a plug for elastic band
    h_elastic_band = 2;

    difference(){
        translate([0,  -w_mold / 2, -h_underground / 2] )
        cube([dia_drain + 5, 5, dia_drain + 2], center = true);
        translate([0,0, -h_underground])
        cylinder(h_mold, d= w_grid + 10 + w_mold_wall);
        //groove for eleastic band
        translate([0,  -w_mold / 2 - 4, -h_underground / 2] )
        cube([dia_drain + 5, 5, h_elastic_band ], center = true);
        
    }
    
}

if(render_drain_plug){
    prototype_drain();
    drain_plug();
}

module area_cross_section(angle = 60){
    h = h_above_ground + h_underground;
    l = dia_city / 2;
    w = dia_city / 2;
    
    
    translate([0,0,h_above_ground])
    rotate([180,0,0])
    linear_extrude(h)
    polygon([[0,0], [l,0], [l,w], [cos(angle), sin(angle)] * l] );
    
}
