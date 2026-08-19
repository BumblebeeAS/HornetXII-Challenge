function startup_challenge()
%STARTUP_CHALLENGE  Runs automatically when the HornetXII Challenge project opens.
%
%   Loads the vehicle and environment parameters into the base workspace.
%   Every block in the model reads from these structs, so the model will not
%   compile until this has run.  If you ever see "Unrecognized function or
%   variable 'Vehicle'", run VehicleParameters again.

evalin('base', 'VehicleParameters');

fprintf('\n  HornetXII Challenge\n');
fprintf('  Vehicle and Environment loaded.\n');
fprintf('  Target cube at NED [%.1f %.1f], %.2f m on a side.\n', ...
        evalin('base', 'Environment.target.xy(1)'), ...
        evalin('base', 'Environment.target.xy(2)'), ...
        evalin('base', 'Environment.target.side'));
fprintf('  Open HornetXII_Challenge.slx to start. See README.md.\n\n');
end
