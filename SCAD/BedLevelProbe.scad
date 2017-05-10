// auto bed leveling sensor

$fn=50;

//cube([5.5,5.5,1.5],center=true);
//cylinder(d=5.1,h=1.1,center=true);

//color("GREEN")translate([0,0,4])cube([12,12,1.6],center=true);

color("WHITE")translate([0,0,-3])pin();


difference(){
     case();
     translate([6.8,-50,-50])cube([100,100,100]);
     translate([5,-6.1,-16])cube([10,12.2,20]);
     translate([-107.8,-50,-50])cube([100,100,100]);
     translate([-50, -107.8,-50])cube([100,100,100]);
     translate([-50, -7.2+15,-50])cube([100,100,100]);
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

module case(){
     difference(){
         union(){
             translate([0,0,-12.5])cube([15.6,15.6,35],center=true);
             translate([0,0,9.5])cylinder(d1=22,d2=8,h=9,center=true);
         }
         translate([0,0,10])cylinder(d=2.6,h=15,center=true);
         //translate([0,0,-11])cylinder(d=13,h=30,center=true);
         translate([0.25,0,-10-14])cube([13.3+0.5,13.3,30],center=true);
         translate([0,0,0-2.5])cube([12.2,12.2,15],center=true);
     }
}