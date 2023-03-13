function SFlabVisualizeResults(varargin)
% SFlabVisualizeResults Plot tracking results
%
% Plots estimated trajectory and microphone positions on top of an image
% of the race track.
%
% SFlabVisualizeResults(setup, traj, parvalues)
%
% INPUTS:
% setup        filename of mat-file contaning information about the current
%              setup
% traj         2xN-vector with the estimated trajectory, first row is
%              X-coordinate, second row is Y-coordinate.  If several
%              2xN-vectors are provided in a cell array, then each
%              trajectory is plotted.  Optional.
% parvalues    Optinal parameter value pair(s).
%              legend: Legend entry to use for the trajectory, if several
%              useadd a cell array of descriptions.

  p = inputParser;
  p.addRequired('setup');
  p.addOptional('traj', {});
  p.addParameter('legend', {});
  p.parse(varargin{:});
  if ~iscell(p.Results.traj)
    traj = { p.Results.traj };
  else
    traj = p.Results.traj;
  end
  if ~iscell(p.Results.legend)
    traj_str = { p.Results.legend };
  else
    traj_str = p.Results.legend;
  end

  load(p.Results.setup);
  legend_str = {'Microphone location'};

  clf
  imagesc(board_img);
  hold on;

  % Plot mics
  M = applyHomography(H, mic_locations);
  plot(M(1, :)', M(2, :)', 'dg','MarkerSize', 15, 'MarkerFaceColor', 'g');

  % Plot trajectories
  for i = 1:numel(traj)
    X = applyHomography(H, traj{i});
    plot(X(1, :), X(2, :), '-x', 'LineWidth', 2, 'MarkerSize', 10);
    if numel(traj_str) >= i
      legend_str{end+1} = traj_str{i};
    else
      legend_str{end+1} = sprintf('Trajectory %g', i);
    end
  end
  legend(legend_str, 'Location', 'SouthEast');
end

function x = applyHomography(H, X)
  x = H * [X; ones(1, size(X, 2))];
  x = x(1:2, :) ./ x(3, :);
end
