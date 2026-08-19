function [J, Rq, Tq] = quatern(q)
%QUATERN  Quaternion transformation matrices for 6-DOF marine craft kinematics.
%
%   [J, Rq, Tq] = QUATERN(Q) takes a unit quaternion Q = [eta eps1 eps2 eps3]
%   describing the BODY frame relative to NED, and returns
%
%       J = [ Rq   0  ]     7x6
%           [ 0    Tq ]
%
%   which maps BODY-frame velocity nu = [u v w p q r]' to the derivative of
%   the position/quaternion state:
%
%       d/dt [x y z eta eps1 eps2 eps3]' = J * nu
%
%   Rq (3x3) is the rotation matrix NED <- BODY.  Tq (4x3) maps BODY angular
%   velocity to quaternion rate.
%
%   Q must be a unit quaternion; QUATERN errors otherwise.  That guard is
%   deliberate -- a non-normalised quaternion here produces a J that looks
%   plausible and is wrong.
%
%   This is a self-contained equivalent of quatern/Rquat/Tquat/Smtrx from the
%   Marine Systems Simulator, collapsed into one file so this project needs no
%   MSS installation.  Behaviour is identical.
%
%   MSS is Copyright (c) 2004 Thor I. Fossen and is distributed under the MIT
%   licence.  https://github.com/cybergalactic/MSS
%   Reference: Fossen, "Handbook of Marine Craft Hydrodynamics and Motion
%   Control", Wiley, 2011 -- eqs. 2.70 and 2.78.

%#codegen

tol = 1e-6;
if abs(norm(q) - 1) > tol
    error('quatern:notUnitQuaternion', ...
          'norm(q) must be 1; got %.6g.', norm(q));
end

eta = q(1);
e1  = q(2);
e2  = q(3);
e3  = q(4);

% Skew-symmetric matrix of the vector part.
S = [  0  -e3   e2
      e3    0  -e1
     -e2   e1    0 ];

% Rotation matrix, NED <- BODY.
Rq = eye(3) + 2*eta*S + 2*(S*S);

% Quaternion rate from BODY angular velocity.
Tq = 0.5 * [ -e1  -e2  -e3
              eta -e3   e2
              e3   eta -e1
             -e2   e1   eta ];

J = [ Rq          zeros(3,3)
      zeros(4,3)  Tq         ];
end
