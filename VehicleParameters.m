% MAIN PARAMETERS

%% Environment

% ref: https://www.sensorsone.com/local-gravity-calculator/
Environment.gravity = 9.78017;      % m/s^2 @ latitude 1.3°, height 58m
Environment.waterdensity = 1000;    % kg/m^3

%% Inertial
Vehicle.CoG = [0 0 0];
Vehicle.mass = 17.30393;            % kg
Vehicle.gravityforcevec = [0;0;Vehicle.mass * Environment.gravity];

swinertial = [0.884851	-0.001743	-0.000354;
            -0.001743	1.028930	-0.002548;
            -0.000354	-0.002548	0.587200;];

Rsw2body = [0 0 1;-1 0 0;0 -1 0];
                                    % kg*m^2
Vehicle.Inertia = Rsw2body * swinertial * Rsw2body.';
Vehicle.Idiag = diag(Vehicle.Inertia);
Vehicle.Ioffdiag = [Vehicle.Inertia(2,3),Vehicle.Inertia(3,1),Vehicle.Inertia(1,2)];
clear swinertial Rsw2body;

%% Hydrostatic
Vehicle.volumeDisplaced = 0.0179;   % m^3 random number to make it float
Vehicle.CoB = [0 0 0.05];           % m   random number a little higher then CG
                                    % N
Vehicle.buoyancyforce = Environment.waterdensity * Environment.gravity * Vehicle.volumeDisplaced;
                                    % dir: -Z
Vehicle.buoyancyforcevec = [0;0;-Vehicle.buoyancyforce];

%% Hydrodynamic
Vehicle.Addedmass = zeros(6,6);     % mixed with kg & kg/m^2

                                    % mixed with N*s/m & N*m*s/rad
Vehicle.lineardampingcoe = [0 0 0 0 0 0];

% using bluerov-heavy's coe. from Dave
                                    % kg/m kg/m kg/m kg*m kg*m kg*m
Vehicle.quadraticdampingcoe = [-58.42 -55.137 -124.818 -4.0 -4.0 -4.0];

%% Thrusters

zdis = 0.15/2;
x1=0.216;
x2=0.216;
x3=0.2417;
x4=0.2417;
y1=0.165;
y2=0.165;
y3=0.2056;
y4=0.2056;

r1 = [x1 y1 -zdis]';
r2 = [x1 -y1 -zdis]';
r3 = [-x2 y2 -zdis]';
r4 = [-x2 -y2 -zdis]';
r5 = [x3 y3 zdis]';
r6 = [x3 -y3 zdis]';
r7 = [-x4 y4 zdis]';
r8 = [-x4 -y4 zdis]';

ve = [0 0 1]'; % vertical (downwards)
nw = [cos(-pi/4),sin(-pi/4),0]'; % towards North-West 
ne = [cos(pi/4),sin(pi/4),0]'; % towards North-East

Vehicle.thrusterpos = [r1 r2 r3 r4 r5 r6 r7 r8];
Vehicle.thrusterori = [ve ve ve ve nw ne ne nw];
clear zdis x1 x2 x3 x4 y1 y2 y3 y4 r1 r2 r3 r4 r5 r6 r7 r8 ve nw ne;

% Orientation of each thruster as a quaternion rotating +Z onto its thrust
% axis.  quat_from_u_to_v (in lib/) is used instead of vrrotvec so this
% project does not depend on Simulink 3D Animation.
thrusterref = [0 0 1];
N = size(Vehicle.thrusterori, 2);
Vehicle.thrusteroriQ = cell2mat(arrayfun( ...
    @(k) quat_from_u_to_v(thrusterref, Vehicle.thrusterori(:,k)).', 1:N, 'uni', false));

clear thrusterref N;



% M = r × f
% cross product of each column : moment
Vehicle.thrustertoq = cross(Vehicle.thrusterpos,Vehicle.thrusterori,1);

Vehicle.thrustercfg = [Vehicle.thrusterori; Vehicle.thrustertoq];

% given the force f and torque t required at CoG
% Vehicle.thrustallocmatrix * [f;t] gives the input vector u ∈ R^8
Vehicle.thrustallocmatrix = pinv(Vehicle.thrustercfg);
%%

% PARAMETERS ONLY FOR SIMSCAPE SIMULATION

Environment.seafloordepth = 2;      % m
Environment.seafloortileside = 2;   % m
Environment.seaflooropacity = 1;    % 0..1
                                    % m m m
Vehicle.bodydisplaysize = [0.6 0.5 0.2];
Vehicle.bodydisplaycolour = [0.3333 0.3333 0.498];
Vehicle.bodydisplayopacity = 0.5;

Vehicle.thrusterdisplayr = 0.06;    % m
Vehicle.thrusterdisplayl = 0.09;    % m
Vehicle.thrusterdisplaycolour = [0 0 1];
Vehicle.thrusterdisplayopacity = 1;

%% Search target
% A red cube resting on the seafloor.  This is the thing to find.
%
% The cube is placed by the Target Object subsystem inside Simulator; these
% values drive it, so moving the target needs no model edit -- change xy,
% re-run this script, re-run the model.

Environment.target.side   = 0.30;               % m
Environment.target.colour = [0.85 0.08 0.08];   % red
Environment.target.xy     = [4.0 -3.0];         % m, NED north/east
                                                % m, cube centre sits on floor
Environment.target.pos    = [Environment.target.xy(:); ...
                             Environment.seafloordepth - Environment.target.side/2];

% Set Environment.target.seed to an integer before running this script to draw
% a random placement instead.  Worth doing once your search works: a search
% that only finds the cube where you left it has not been tested.
if isfield(Environment.target, 'seed') && ~isempty(Environment.target.seed)
    rs = RandStream('twister', 'Seed', Environment.target.seed);
    Environment.target.xy  = [rand(rs)*12-6, rand(rs)*12-6];
    Environment.target.pos = [Environment.target.xy(:); ...
                              Environment.seafloordepth - Environment.target.side/2];
    clear rs;
end
