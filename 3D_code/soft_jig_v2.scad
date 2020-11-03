//(c) Inne Lemstra 12-10-20

$fn = 20;

//v2 Top mold will use externa metal (manhole) pipes instead of 3D printed ones


//to do:
//refactor code
//model electric poles without spheres to remove render()
//drain pour protection should be longer


//v_(next ideas)
    //variable array plaza en street size for different components in same jig
    //make list of components you might want to solder
    //make allow_outside_city param more reliable

render_jig = false;  //render Jig object as 3D object
    render_cross_section = true;
render_mold = true; //render a mold with which to make the 3D object
    render_mold_above_ground = false;
    render_mold_underground = true;
    render_mold_combine_tube = false;



dia_city = 100;
w_city_wall = 10;

//buillding
w_building = 10;
l_building =  w_building;   //buildings are square
h_building = 3;

w_street = .8;


dia_manhole = 0.81;    // 1206 LED is 3.2mm by 1.6 mm
h_manhole_pipe = 0.5; //transision cone between manhole and pipe
ny_manhole = 2;
dia_plaza = dia_manhole * 6 ;

h_ground = 2;
h_above_ground = h_ground + h_building;

dia_drain = 6;
l_drain  = 15;
dia_pipe  = 1;
h_foundation = 10;
dia_foundation = w_building * 0.8;
h_bedrock = 3;
l_drain_support = l_drain *1.5;
w_drain_support = dia_drain + 5;

h_underground = h_foundation + h_bedrock;

//mold variables
h_mold_bottom = 3;
h_mold_ceiling = 3;
w_mold_wall = 3;
h_mold_buffer = 2; //buffer space to prevent overflow
w_mold_wall_combine = 4;
//ring along inside wall to indicate end fluid level
h_fluid_ring = h_mold_buffer; 
w_fluid_ring = 1 ; //
l_tube_protection = 1;


nx_buildings = ceil(dia_city / l_building);        //number of buildings in x direction
ny_buildings = ceil(dia_city / w_building) ;    //number of buildings in y direction


l_grid = (l_building + w_street) * nx_buildings - w_street; //grid of buildings
w_grid = (w_building + w_street) * nx_buildings - w_street; 


if (render_jig){
    difference(){
        make_model();
        if(render_cross_section){
            area_cross_section();
        }
    }
}
   
    
if (render_mold) make_mold();

/////////debug shit///////////

//  make_grid()//allow_outside_city = false, w_boundries = [dia_plaza, dia_plaza]) 
//plaza();
//
//translate([l_grid / 2, w_grid / 2, 0])
//#cylinder(h = 0.5, d = dia_city);

/////////////////////////////////

module plaza(center = false){
   if(center){
       cylinder(h_building + .1, d=dia_plaza); //have plaza at origin
   }else{
       translate ([w_street / -2, w_street / -2, 0]) 
        cylinder(h_building + .1, d=dia_plaza); // have plaza in the middle of a street intersection.
   }
}
 
module building() cube([l_building, w_building, h_building], center = false);


module make_model(){
    make_above_ground();
    make_underground();
    
}

module grid_to_origin() translate([l_grid / -2, w_grid / -2, 0]) children();

module move_to_crossroad()translate ([w_street/-2, w_street /-2, 0]) children() ;

module cylinder_to_building() translate([l_building / 2, w_building / 2, 0]) children();

module make_grid(allow_outside_city = true, w_boundries = [0,0], nx = nx_buildings, ny = ny_buildings){
        
    union(){
        for(i = [(-nx +1) / 2 : 1 :(nx -1) / 2]){
            for(j = [(-ny + 1 )/2 : 1 : (ny -1) /2 ]){
                x_building = ((l_building +w_street) * i ) +l_building / 2;
                y_building = ((w_building +w_street)*j ) + w_building /2;
                //pythogoras incoming
                if(allow_outside_city || (
                    pow( - x_building , 2) +
                        pow(w_boundries[0], 2) +
                    pow(- y_building , 2) +
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


module make_above_ground(){

difference(){
        cylinder(h_ground,  d = dia_city);
    //to make an acutrate representation how the jig will look
    //even though rods will be added after printing so can't be used when making mold
    if (render_jig)  #make_grid(allow_outside_city = false, ny = 2) move_to_crossroad() render() electric_pole();
    }
     intersection(){
        union(){
        //move above the ground
        translate([0,0, h_ground]){
            difference(){
                //place building
                make_grid(allow_outside_city = false) building();
             make_grid() plaza();
            }
        }
    }
        //shape of city
        cylinder(h_ground + h_building, d = dia_city);
}
    
    
}


module make_underground(){

    difference(){
        foundation();
        location_drainage();
    }
    difference(){
    translate([0,0, -h_underground])
    cylinder(h_underground, d= dia_city);
        translate([0, w_building * 1.2 /2.1, -h_underground / 2])
        cube([dia_city, ny_manhole * w_building *1.2 ,h_underground] , center = true);
    }
   make_wall();
    color("grey")
    bedrock();
    make_drainage();
    

}

module foundation() {
    intersection(){
        union(){
        translate([0,0,-h_foundation])
        make_grid(allow_outside_city = false, w_boundries = [-w_city_wall - w_building , -w_city_wall - w_building], ny = ny_manhole) 
            cylinder_to_building()cylinder(h_foundation, d =dia_foundation);    
    }
    translate([0,0, -h_foundation])
    cylinder(h_foundation, d= dia_city);
    }
}


module make_wall() {
    difference(){
            translate([0,0, -h_underground]){
                difference(){
        cylinder(h = h_underground , d = dia_city );
         translate([0,0, -.1])
        cylinder(h = h_underground + 0.2, d = dia_city - w_city_wall);
                }
            }
       drain_pipe();
    }
}

module bedrock() {
    translate([0,0, -h_underground])
    cylinder(h_bedrock, d =dia_city);
}

module make_drainage(){
    intersection(){
    union(){
    //pipe support
        difference(){
            translate([dia_city/2 - l_drain_support, - w_drain_support /2, -h_foundation])
            cube([l_drain_support, w_drain_support, h_foundation / 2]);
            translate([-l_drain_support - l_drain  ,0,0])
            resize([l_drain_support, 0,0])
            drain_pipe(); 
            #drain_pipe(); // for visualisation
            //give air space to drain away by making gaps in support
            translate([dia_city / 2 - l_drain_support, -w_drain_support / 2, -h_foundation /2 - dia_drain /1.9])
            #cube([l_drain_support - l_drain, w_drain_support, dia_drain / 1.9]);
            
        }
    }
    translate([0,0, - h_foundation])
    cylinder(h_foundation, d = dia_city);
    }
   
}


module drain_pipe(){
    translate([dia_city/2 - l_drain,0, - h_foundation / 2])
    rotate([0,90,0])
    cylinder(l_drain, d = dia_drain);
    
}


module location_drainage(){
    //shape of outline drainage with same heigth as foundation
    //to cleare underground area above/below drainage
    intersection(){
        translate([dia_city / 2 - l_drain_support, -w_drain_support/2, -h_foundation])
        cube([ l_drain_support, w_drain_support,h_foundation]);
        rotate([180,0,0])
        cylinder(h_underground, d=dia_city) ;
    }
}



module make_mold(){
    if(render_mold_above_ground) mold_above_ground();
    if(render_mold_underground) mold_underground();
    if(render_mold_combine_tube) mold_combine_tube();          
}

module mold_above_ground(){
    difference(){
        cylinder(h_above_ground + h_mold_ceiling, d = dia_city + w_mold_wall);
        make_above_ground();
         #make_grid(allow_outside_city = false, nx = 8,ny = ny_manhole) move_to_crossroad() render() electric_pole();
    }
    
    //some buffer space when pouring silicone
    //elongate manhole pipes
//    intersection(){
//        union(){
//            translate([0,0, -h_mold_buffer])
//            //manhole pipes
//            make_grid() move_to_crossroad() cylinder(h_mold_buffer, d=dia_manhole);
//        }
//        translate([0,0,-h_mold_buffer])
//        cylinder(h_mold_buffer, d=dia_city);
//    }
    //higer walls
    translate([0,0, - h_mold_buffer])
    difference(){
        cylinder(h_mold_buffer, d= dia_city + w_mold_wall);
        cylinder(h_mold_buffer, d= dia_city);
        //carve ring to indicate correct fluid level
        cylinder(h_fluid_ring, d= dia_city + w_fluid_ring);
    }
    
}


module mold_underground(){
        difference(){
            translate([0,0, h_mold_bottom])
            rotate([180,0,0])
        cylinder(h_underground + h_mold_bottom, d = dia_city + w_mold_wall);
        make_underground();
            //cut out hole for drain pipe also into protection block
            translate([dia_city / 2 - l_drain,0, -h_foundation /2])
            translate([-l_tube_protection -2,0,0])
            #resize([l_drain + l_tube_protection + w_mold_wall + 1,0,0])
            rotate([0,90,0])
            cylinder(l_drain, d=dia_drain);
    }
    
}

module mold_combine_tube(){ //depricated
    //a hollow tube with bottom to insert both mold parts for glueing
    difference(){
        cylinder(h_underground + h_above_ground + h_mold_bottom, d= dia_city + w_mold_wall_combine);
        translate([0,0, h_mold_bottom])
        cylinder(h_underground + h_above_ground, d= dia_city);
    }
}





module electric_pole(){
    union(){
    h_electric_pole = h_above_ground + h_mold_ceiling - dia_manhole;
    cylinder(h_electric_pole, d= dia_manhole);
    translate([0,0, h_electric_pole]){
        sphere(d= dia_manhole);
        //translate([-dia_manhole, -dia_manhole, 0] / 2)
        rotate([-90,0,0])
        cylinder( w_building* 0.7, d= dia_manhole);
        rotate([0,0,90])
        translate([-dia_manhole, -dia_manhole, 0] /2)
        cube([w_building*0.7 + dia_manhole , dia_manhole, dia_manhole *4]);
        translate([0, w_building * 0.7, 0]){
               sphere(d= dia_manhole);
                translate([0,0, - h_mold_ceiling *0.8])
                cylinder(h_mold_ceiling *0.8, d=dia_manhole);
        }
    }
}
}


//electric_pole();

module area_cross_section(angle = 60){
    h = h_above_ground + h_underground;
    l = dia_city / 2;
    w = dia_city / 2;
    
    
    translate([0,0,h_above_ground])
    rotate([180,0,0])
    linear_extrude(h)
    polygon([[0,0], [l,0], [l,w], [cos(angle), sin(angle)] * l] );
    
}