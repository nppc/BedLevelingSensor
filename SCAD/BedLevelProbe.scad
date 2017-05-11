// auto bed leveling sensor

$fn=100;

//color("WHITE")translate([0,0,-3])pin();
//casecover();
case();

module case(){
    difference(){
         case_mold();
         translate([0, -7.2,-26])screwhole(1.3);
         translate([0, 7.2,-26])screwhole(1.3);
         translate([5, 0,7])screwhole(1.3);
         translate([6.8,-50,-50])cube([100,100,100]);
         translate([5,-6.1,-16])cube([10,12.2,20]);
         translate([-107.8,-50,-50])cube([100,100,100]);
         translate([-50, -107.8,-50])cube([100,100,100]);
         translate([-50, -7.2+15,-50])cube([100,100,100]);
    }
    translate([0, -7.2,-26])screwhousing(13.6,1.3);
    translate([0, 7.2,-26])screwhousing(13.6,1.3);
}


module pin(){
    union(){
        difference(){
            translate([0,0,1.5])cylinder(d=10,h=8, center=true);
            translate([0,0,-3])cylindercube(2,6,3);
            translate([0,0,-1])cylindercube(7,10,2.2);
            translate([0,0,4])cylinder(d=2.3,h=4, center=true);
            translate([0,7.7,1])cube([10,10,10],center=true);
        }
        
    }
}


module cylindercube(diam,length,height){
    hull(){
        cylinder(d=diam,h=height);
        translate([-diam/2,0,0])cube([diam,length-diam/2,height]);
    }
}

module case_mold(){
     difference(){
         union(){
             translate([0,0,-11.5])cube([15.6,15.6,33],center=true);
             translate([0,0,9.5])cylinder(d1=22,d2=8,h=9,center=true);
         }
         translate([0,0,10])cylinder(d=2.6,h=15,center=true);
         translate([0.25,0,-7.5-14])cube([13.2+0.5,13.2,25],center=true);
         translate([0,0,0-15])cube([12.2,12.2,40],center=true);
         translate([0,0,0-25])cube([13.2,13.2,12],center=true);
     }
}

module screwhole(diam){
    translate([2,0,0])rotate([0,90,0])cylinder(d=diam, h=10, center=true);
}

module screwhousing(hght,diam){
    rotate([0,90,0])difference(){
        cylinder(d=4, h=hght, center=true);
        translate([0,0,2])cylinder(d=diam, h=10, center=true);
    }
}

module screwhead(diam){
    translate([8.8-0.7,0,0])rotate([0,90,0])cylinder(d=diam, h=1, center=true);
}

module casecover(){
    difference(){
        union(){
            translate([7.55,0,-9])cube([1.5,15.5,38], center=true);
            translate([7.55, -7.2,-26])screwhousing(1.5,1.6);
            translate([7.55, 7.2,-26])screwhousing(1.5,1.6);
       }
       translate([6.3+0.8, 0,-18])cube([1,7,17], center=true);
       translate([0, 10,16])rotate([-35,0,0])cube([20,20,20], center=true);
       translate([0, -10,16])rotate([35,0,0])cube([20,20,20], center=true);
       translate([5, -7.2,-26])screwhole(1.6);
       translate([5, 7.2,-26])screwhole(1.6);
       translate([5, 0,7])screwhole(1.6);
       
       translate([0, -7.2,-26])screwhead(2.4);
       translate([0, 7.2,-26])screwhead(2.4);
       translate([0, 0,7])screwhead(2.4);
       
    }
}