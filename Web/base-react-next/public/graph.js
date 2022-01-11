/*
 *  Copyright (c) 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree.
 */
// taken from chrome://webrtc-internals with jshint adaptions

'use strict';
/* exported TimelineDataSeries, TimelineGraphView */

const TimelineDataSeries = (function() {
  /**
   * @constructor
   */
  function TimelineDataSeries() {
    // List of DataPoints in chronological order.
    this.dataPoints_ = [];

    // Default color.  Should always be overridden prior to display.
    this.color_ = 'red';
    // Whether or not the data series should be drawn.
    this.isVisible_ = true;

    this.cacheStartTime_ = null;
    this.cacheStepSize_ = 0;
    this.cacheValues_ = [];
    // The maximum number of data points bufferred for each stats. Old data points
    // will be shifted out when the buffer is full.
    this.maxStatsDataPointBufferSize = 1000;
  }

  TimelineDataSeries.prototype = {
    /**
     * @override
     */
    toJSON: function() {
      if (this.dataPoints_.length < 1) {
        return {};
      }

      let values = [];
      for (let i = 0; i < this.dataPoints_.length; ++i) {
        values.push(this.dataPoints_[i].value);
      }
      return {
        startTime: this.dataPoints_[0].time,
        endTime: this.dataPoints_[this.dataPoints_.length - 1].time,
        values: JSON.stringify(values),
      };
    },

    /**
     * Adds a DataPoint to |this| with the specified time and value.
     * DataPoints are assumed to be received in chronological order.
     */
    addPoint: function(timeTicks, value) {
      let time = new Date(timeTicks);
      this.dataPoints_.push(new DataPoint(time, value));

      if (this.dataPoints_.length > this.maxStatsDataPointBufferSize) {
        this.dataPoints_.shift();
      }
    },

    isVisible: function() {
      return this.isVisible_;
    },

    show: function(isVisible) {
      this.isVisible_ = isVisible;
    },

    getColor: function() {
      return this.color_;
    },

    setColor: function(color) {
      this.color_ = color;
    },

    getCount: function() {
      return this.dataPoints_.length;
    },
    /**
     * Returns a list containing the values of the data series at |count|
     * points, starting at |startTime|, and |stepSize| milliseconds apart.
     * Caches values, so showing/hiding individual data series is fast.
     */
    getValues: function(startTime, stepSize, count) {
      // Use cached values, if we can.
      if (this.cacheStartTime_ === startTime &&
        this.cacheStepSize_ === stepSize &&
        this.cacheValues_.length === count) {
        return this.cacheValues_;
      }

      // Do all the work.
      this.cacheValues_ = this.getValuesInternal_(startTime, stepSize, count);
      this.cacheStartTime_ = startTime;
      this.cacheStepSize_ = stepSize;

      return this.cacheValues_;
    },

    /**
     * Returns the cached |values| in the specified time period.
     */
    getValuesInternal_: function(startTime, stepSize, count) {
      let values = [];
      let nextPoint = 0;
      let currentValue = 0;
      let time = startTime;
      for (let i = 0; i < count; ++i) {
        while (nextPoint < this.dataPoints_.length &&
        this.dataPoints_[nextPoint].time < time) {
          currentValue = this.dataPoints_[nextPoint].value;
          ++nextPoint;
        }
        values[i] = currentValue;
        time += stepSize;
      }
      return values;
    }
  };

  /**
   * A single point in a data series.  Each point has a time, in the form of
   * milliseconds since the Unix epoch, and a numeric value.
   * @constructor
   */
  function DataPoint(time, value) {
    this.time = time;
    this.value = value;
  }

  return TimelineDataSeries;
})();

const TimelineGraphView = (function() {
  // Maximum number of labels placed vertically along the sides of the graph.
  let MAX_VERTICAL_LABELS = 6;

  // Vertical spacing between labels and between the graph and labels.
  let LABEL_VERTICAL_SPACING = 4;
  // Horizontal spacing between vertically placed labels and the edges of the
  // graph.
  let LABEL_HORIZONTAL_SPACING = 3;
  // Horizintal spacing between two horitonally placed labels along the bottom
  // of the graph.
  // var LABEL_LABEL_HORIZONTAL_SPACING = 25;

  // Length of ticks, in pixels, next to y-axis labels.  The x-axis only has
  // one set of labels, so it can use lines instead.
  let Y_AXIS_TICK_LENGTH = 10;

  let GRID_COLOR = '#CCC';
  let TEXT_COLOR = '#000';
  let BACKGROUND_COLOR = '#FFF';

  let MAX_DECIMAL_PRECISION = 2;

  /**
   * @constructor
   */
  function TimelineGraphView(divId, canvasId) {
    this.scrollbar_ = {position_: 0, range_: 0};

    this.graphDiv_ = document.getElementById(divId);
    this.canvas_ = document.getElementById(canvasId);

    // Set the range and scale of the graph.  Times are in milliseconds since
    // the Unix epoch.

    // All measurements we have must be after this time.
    this.startTime_ = 0;
    // The current rightmost position of the graph is always at most this.
    this.endTime_ = 1;

    this.graph_ = null;

    // Horizontal scale factor, in terms of milliseconds per pixel.
    this.scale_ = 1000;

    // Initialize the scrollbar.
    this.updateScrollbarRange_(true);
  }

  TimelineGraphView.prototype = {
    setScale: function(scale) {
      this.scale_ = scale;
    },

    // Returns the total length of the graph, in pixels.
    getLength_: function() {
      let timeRange = this.endTime_ - this.startTime_;
      // Math.floor is used to ignore the last partial area, of length less
      // than this.scale_.
      return Math.floor(timeRange / this.scale_);
    },

    /**
     * Returns true if the graph is scrolled all the way to the right.
     */
    graphScrolledToRightEdge_: function() {
      return this.scrollbar_.position_ === this.scrollbar_.range_;
    },

    /**
     * Update the range of the scrollbar.  If |resetPosition| is true, also
     * sets the slider to point at the rightmost position and triggers a
     * repaint.
     */
    updateScrollbarRange_: function(resetPosition) {
      let scrollbarRange = this.getLength_() - this.canvas_.width;
      if (scrollbarRange < 0) {
        scrollbarRange = 0;
      }

      // If we've decreased the range to less than the current scroll position,
      // we need to move the scroll position.
      if (this.scrollbar_.position_ > scrollbarRange) {
        resetPosition = true;
      }

      this.scrollbar_.range_ = scrollbarRange;
      if (resetPosition) {
        this.scrollbar_.position_ = scrollbarRange;
        this.repaint();
      }
    },

    /**
     * Sets the date range displayed on the graph, switches to the default
     * scale factor, and moves the scrollbar all the way to the right.
     */
    setDateRange: function(startDate, endDate) {
      this.startTime_ = startDate.getTime();
      this.endTime_ = endDate.getTime();

      // Safety check.
      if (this.endTime_ <= this.startTime_) {
        this.startTime_ = this.endTime_ - 1;
      }

      this.updateScrollbarRange_(true);
    },

    /**
     * Updates the end time at the right of the graph to be the current time.
     * Specifically, updates the scrollbar's range, and if the scrollbar is
     * all the way to the right, keeps it all the way to the right.  Otherwise,
     * leaves the view as-is and doesn't redraw anything.
     */
    updateEndDate: function(optDate) {
      this.endTime_ = optDate || (new Date()).getTime();
      this.updateScrollbarRange_(this.graphScrolledToRightEdge_());
    },

    getStartDate: function() {
      return new Date(this.startTime_);
    },

    /**
     * Replaces the current TimelineDataSeries with |dataSeries|.
     */
    setDataSeries: function(dataSeries) {
      // Simply recreates the Graph.
      this.graph_ = new Graph();
      for (let i = 0; i < dataSeries.length; ++i) {
        this.graph_.addDataSeries(dataSeries[i]);
      }
      this.repaint();
    },

    /**
     * Adds |dataSeries| to the current graph.
     */
    addDataSeries: function(dataSeries) {
      if (!this.graph_) {
        this.graph_ = new Graph();
      }
      this.graph_.addDataSeries(dataSeries);
      this.repaint();
    },

    /**
     * Draws the graph on |canvas_|.
     */
    repaint: function() {
      this.repaintTimerRunning_ = false;

      let width = this.canvas_.width;
      let height = this.canvas_.height;
      let context = this.canvas_.getContext('2d');

      // Clear the canvas.
      context.fillStyle = BACKGROUND_COLOR;
      context.fillRect(0, 0, width, height);

      // Try to get font height in pixels.  Needed for layout.
      let fontHeightString = context.font.match(/([0-9]+)px/)[1];
      let fontHeight = parseInt(fontHeightString);

      // Safety check, to avoid drawing anything too ugly.
      if (fontHeightString.length === 0 || fontHeight <= 0 ||
        fontHeight * 4 > height || width < 50) {
        return;
      }

      // Save current transformation matrix so we can restore it later.
      context.save();

      // The center of an HTML canvas pixel is technically at (0.5, 0.5).  This
      // makes near straight lines look bad, due to anti-aliasing.  This
      // translation reduces the problem a little.
      context.translate(0.5, 0.5);

      // Figure out what time values to display.
      let position = this.scrollbar_.position_;
      // If the entire time range is being displayed, align the right edge of
      // the graph to the end of the time range.
      if (this.scrollbar_.range_ === 0) {
        position = this.getLength_() - this.canvas_.width;
      }
      let visibleStartTime = this.startTime_ + position * this.scale_;

      // Make space at the bottom of the graph for the time labels, and then
      // draw the labels.
      let textHeight = height;
      height -= fontHeight + LABEL_VERTICAL_SPACING;
      this.drawTimeLabels(context, width, height, textHeight, visibleStartTime);

      // Draw outline of the main graph area.
      context.strokeStyle = GRID_COLOR;
      context.strokeRect(0, 0, width - 1, height - 1);

      if (this.graph_) {
        // Layout graph and have them draw their tick marks.
        this.graph_.layout(
          width, height, fontHeight, visibleStartTime, this.scale_);
        this.graph_.drawTicks(context);

        // Draw the lines of all graphs, and then draw their labels.
        this.graph_.drawLines(context);
        this.graph_.drawLabels(context);
      }

      // Restore original transformation matrix.
      context.restore();
    },

    /**
     * Draw time labels below the graph.  Takes in start time as an argument
     * since it may not be |startTime_|, when we're displaying the entire
     * time range.
     */
    drawTimeLabels: function(context, width, height, textHeight, startTime) {
      // Draw the labels 1 minute apart.
      let timeStep = 1000 * 60;

      // Find the time for the first label.  This time is a perfect multiple of
      // timeStep because of how UTC times work.
      let time = Math.ceil(startTime / timeStep) * timeStep;

      context.textBaseline = 'bottom';
      context.textAlign = 'center';
      context.fillStyle = TEXT_COLOR;
      context.strokeStyle = GRID_COLOR;

      // Draw labels and vertical grid lines.
      while (true) {
        let x = Math.round((time - startTime) / this.scale_);
        if (x >= width) {
          break;
        }
        let text = (new Date(time)).toLocaleTimeString();
        context.fillText(text, x, textHeight);
        context.beginPath();
        context.lineTo(x, 0);
        context.lineTo(x, height);
        context.stroke();
        time += timeStep;
      }
    },

    getDataSeriesCount: function() {
      if (this.graph_) {
        return this.graph_.dataSeries_.length;
      }
      return 0;
    },

    hasDataSeries: function(dataSeries) {
      if (this.graph_) {
        return this.graph_.hasDataSeries(dataSeries);
      }
      return false;
    },

  };

  /**
   * A Graph is responsible for drawing all the TimelineDataSeries that have
   * the same data type.  Graphs are responsible for scaling the values, laying
   * out labels, and drawing both labels and lines for its data series.
   */
  const Graph = (function() {
    /**
     * @constructor
     */
    function Graph() {
      this.dataSeries_ = [];

      // Cached properties of the graph, set in layout.
      this.width_ = 0;
      this.height_ = 0;
      this.fontHeight_ = 0;
      this.startTime_ = 0;
      this.scale_ = 0;

      // The lowest/highest values adjusted by the vertical label step size
      // in the displayed range of the graph. Used for scaling and setting
      // labels.  Set in layoutLabels.
      this.min_ = 0;
      this.max_ = 0;

      // Cached text of equally spaced labels.  Set in layoutLabels.
      this.labels_ = [];
    }

    /**
     * A Label is the label at a particular position along the y-axis.
     * @constructor
     */
    /*
    function Label(height, text) {
      this.height = height;
      this.text = text;
    }
    */

    Graph.prototype = {
      addDataSeries: function(dataSeries) {
        this.dataSeries_.push(dataSeries);
      },

      hasDataSeries: function(dataSeries) {
        for (let i = 0; i < this.dataSeries_.length; ++i) {
          if (this.dataSeries_[i] === dataSeries) {
            return true;
          }
        }
        return false;
      },

      /**
       * Returns a list of all the values that should be displayed for a given
       * data series, using the current graph layout.
       */
      getValues: function(dataSeries) {
        if (!dataSeries.isVisible()) {
          return null;
        }
        return dataSeries.getValues(this.startTime_, this.scale_, this.width_);
      },

      /**
       * Updates the graph's layout.  In particular, both the max value and
       * label positions are updated.  Must be called before calling any of the
       * drawing functions.
       */
      layout: function(width, height, fontHeight, startTime, scale) {
        this.width_ = width;
        this.height_ = height;
        this.fontHeight_ = fontHeight;
        this.startTime_ = startTime;
        this.scale_ = scale;

        // Find largest value.
        let max = 0;
        let min = 0;
        for (let i = 0; i < this.dataSeries_.length; ++i) {
          let values = this.getValues(this.dataSeries_[i]);
          if (!values) {
            continue;
          }
          for (let j = 0; j < values.length; ++j) {
            if (values[j] > max) {
              max = values[j];
            } else if (values[j] < min) {
              min = values[j];
            }
          }
        }

        this.layoutLabels_(min, max);
      },

      /**
       * Lays out labels and sets |max_|/|min_|, taking the time units into
       * consideration.  |maxValue| is the actual maximum value, and
       * |max_| will be set to the value of the largest label, which
       * will be at least |maxValue|. Similar for |min_|.
       */
      layoutLabels_: function(minValue, maxValue) {
        if (maxValue - minValue < 1024) {
          this.layoutLabelsBasic_(minValue, maxValue, MAX_DECIMAL_PRECISION);
          return;
        }

        // Find appropriate units to use.
        let units = ['', 'k', 'M', 'G', 'T', 'P'];
        // Units to use for labels.  0 is '1', 1 is K, etc.
        // We start with 1, and work our way up.
        let unit = 1;
        minValue /= 1024;
        maxValue /= 1024;
        while (units[unit + 1] && maxValue - minValue >= 1024) {
          minValue /= 1024;
          maxValue /= 1024;
          ++unit;
        }

        // Calculate labels.
        this.layoutLabelsBasic_(minValue, maxValue, MAX_DECIMAL_PRECISION);

        // Append units to labels.
        for (let i = 0; i < this.labels_.length; ++i) {
          this.labels_[i] += ' ' + units[unit];
        }

        // Convert |min_|/|max_| back to unit '1'.
        this.min_ *= Math.pow(1024, unit);
        this.max_ *= Math.pow(1024, unit);
      },

      /**
       * Same as layoutLabels_, but ignores units.  |maxDecimalDigits| is the
       * maximum number of decimal digits allowed.  The minimum allowed
       * difference between two adjacent labels is 10^-|maxDecimalDigits|.
       */
      layoutLabelsBasic_: function(minValue, maxValue, maxDecimalDigits) {
        this.labels_ = [];
        let range = maxValue - minValue;
        // No labels if the range is 0.
        if (range === 0) {
          this.min_ = this.max_ = maxValue;
          return;
        }

        // The maximum number of equally spaced labels allowed.  |fontHeight_|
        // is doubled because the top two labels are both drawn in the same
        // gap.
        let minLabelSpacing = 2 * this.fontHeight_ + LABEL_VERTICAL_SPACING;

        // The + 1 is for the top label.
        let maxLabels = 1 + this.height_ / minLabelSpacing;
        if (maxLabels < 2) {
          maxLabels = 2;
        } else if (maxLabels > MAX_VERTICAL_LABELS) {
          maxLabels = MAX_VERTICAL_LABELS;
        }

        // Initial try for step size between conecutive labels.
        let stepSize = Math.pow(10, -maxDecimalDigits);
        // Number of digits to the right of the decimal of |stepSize|.
        // Used for formating label strings.
        let stepSizeDecimalDigits = maxDecimalDigits;

        // Pick a reasonable step size.
        while (true) {
          // If we use a step size of |stepSize| between labels, we'll need:
          //
          // Math.ceil(range / stepSize) + 1
          //
          // labels.  The + 1 is because we need labels at both at 0 and at
          // the top of the graph.

          // Check if we can use steps of size |stepSize|.
          if (Math.ceil(range / stepSize) + 1 <= maxLabels) {
            break;
          }
          // Check |stepSize| * 2.
          if (Math.ceil(range / (stepSize * 2)) + 1 <= maxLabels) {
            stepSize *= 2;
            break;
          }
          // Check |stepSize| * 5.
          if (Math.ceil(range / (stepSize * 5)) + 1 <= maxLabels) {
            stepSize *= 5;
            break;
          }
          stepSize *= 10;
          if (stepSizeDecimalDigits > 0) {
            --stepSizeDecimalDigits;
          }
        }

        // Set the min/max so it's an exact multiple of the chosen step size.
        this.max_ = Math.ceil(maxValue / stepSize) * stepSize;
        this.min_ = Math.floor(minValue / stepSize) * stepSize;

        // Create labels.
        for (let label = this.max_; label >= this.min_; label -= stepSize) {
          this.labels_.push(label.toFixed(stepSizeDecimalDigits));
        }
      },

      /**
       * Draws tick marks for each of the labels in |labels_|.
       */
      drawTicks: function(context) {
        let x1;
        let x2;
        x1 = this.width_ - 1;
        x2 = this.width_ - 1 - Y_AXIS_TICK_LENGTH;

        context.fillStyle = GRID_COLOR;
        context.beginPath();
        for (let i = 1; i < this.labels_.length - 1; ++i) {
          // The rounding is needed to avoid ugly 2-pixel wide anti-aliased
          // lines.
          let y = Math.round(this.height_ * i / (this.labels_.length - 1));
          context.moveTo(x1, y);
          context.lineTo(x2, y);
        }
        context.stroke();
      },

      /**
       * Draws a graph line for each of the data series.
       */
      drawLines: function(context) {
        // Factor by which to scale all values to convert them to a number from
        // 0 to height - 1.
        let scale = 0;
        let bottom = this.height_ - 1;
        if (this.max_) {
          scale = bottom / (this.max_ - this.min_);
        }

        // Draw in reverse order, so earlier data series are drawn on top of
        // subsequent ones.
        for (let i = this.dataSeries_.length - 1; i >= 0; --i) {
          let values = this.getValues(this.dataSeries_[i]);
          if (!values) {
            continue;
          }
          context.strokeStyle = this.dataSeries_[i].getColor();
          context.beginPath();
          for (let x = 0; x < values.length; ++x) {
            // The rounding is needed to avoid ugly 2-pixel wide anti-aliased
            // horizontal lines.
            context.lineTo(
              x, bottom - Math.round((values[x] - this.min_) * scale));
          }
          context.stroke();
        }
      },

      /**
       * Draw labels in |labels_|.
       */
      drawLabels: function(context) {
        if (this.labels_.length === 0) {
          return;
        }
        let x = this.width_ - LABEL_HORIZONTAL_SPACING;

        // Set up the context.
        context.fillStyle = TEXT_COLOR;
        context.textAlign = 'right';

        // Draw top label, which is the only one that appears below its tick
        // mark.
        context.textBaseline = 'top';
        context.fillText(this.labels_[0], x, 0);

        // Draw all the other labels.
        context.textBaseline = 'bottom';
        let step = (this.height_ - 1) / (this.labels_.length - 1);
        for (let i = 1; i < this.labels_.length; ++i) {
          context.fillText(this.labels_[i], x, step * i);
        }
      }
    };

    return Graph;
  })();

  return TimelineGraphView;
})();
