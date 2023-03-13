function SFlabAnimateResults(varargin)
% SFlabAnimateResults Plot tracking results
%
% Plots estimated trajectory and microphone positions on top of an image
% of the race track.
%
% SFlabAnimateResults(setup, traj, t, parvalues)
%
% INPUTS:
% setup        filename of mat-file contaning information about the current
%              setup
% movie        filename of movie to overload estimates on
% traj         2xN-vector with the estimated trajectory, first row is
%              X-coordinate, second row is Y-coordinate.  If several
%              2xN-vectors are provided in a cell array, then each
%              trajectory is plotted.  Optional.
% t            1xN-vector with times associated with given trajectories.
%              The same number of time series as trajectories must be
%              provided.  Optional.
% parvalues    Optinal parameter value pair(s).
%              legend: Legend entry to use for the trajectory, if several
%              useadd a cell array of descriptions.
%              tail: number of seconds in the tail of the displayed
%              trajectory.

  p = inputParser;
  p.addRequired('setup');
  p.addRequired('movie');
  p.addOptional('traj', {});
  p.addOptional('tobs', {});
  p.addParameter('legend', {});
  p.addParameter('tail', 2);
  p.parse(varargin{:});
  if ~iscell(p.Results.traj)
    traj = { p.Results.traj };
  else
    traj = p.Results.traj;
  end
  if ~iscell(p.Results.tobs)
    tobs = { p.Results.tobs };
  else
    tobs = p.Results.tobs;
  end
  if ~iscell(p.Results.legend)
    traj_str = { p.Results.legend };
  else
    traj_str = p.Results.legend;
  end
  if numel(traj) ~= numel(tobs)
    error('You must provide exactly as many time series as trajectories.');
  else
    for i = 1:numel(traj)
      if size(traj{i}, 2) ~= numel(tobs{i})
        error('Trajectory %g: Number of states and times must agree.', i);
      end
    end
  end

  load(p.Results.setup);
  legend_str = {'Microphone location'};

  M = applyHomography(H, mic_locations);
  for i = 1:numel(traj)
    X{i} = applyHomography(H, traj{i});
  end
  movie = VideoReader(p.Results.movie);

  clf;
  img = imagesc(movie.readFrame);
  hold on
  plot(M(1, :)', M(2, :)', 'dg','MarkerSize', 15, 'MarkerFaceColor', 'g');
  Xh = matlab.graphics.chart.primitive.Line(0);
  for i = 1:numel(traj)
    X{i} = applyHomography(H, traj{i});
    Xh(i) = plot(X{i}(1, 1), X{i}(2, 1), 'x-', 'LineWidth', 2, 'MarkerSize', 10);
    if numel(traj_str) >= i
      legend_str{end+1} = traj_str{i};
    else
      legend_str{end+1} = sprintf('Trajectory %g', i);
    end
  end
  legend(legend_str, 'Location', 'SouthEast');
  Ts = 1/movie.frameRate;

  t = 0;
  while movie.hasFrame
    t = t + Ts;
    set(img, 'CData', movie.readFrame);
    for i = 1:numel(X)
      I = tobs{i} >= (t-p.Results.tail) & tobs{i} <= t;
      set(Xh(i), 'XData', X{i}(1, I), 'YData', X{i}(2, I));
    end
    drawnow;
  end
end

function x = applyHomography(H, X)
  x = H * [X; ones(1, size(X, 2))];
  x = x(1:2, :) ./ x(3, :);
end
