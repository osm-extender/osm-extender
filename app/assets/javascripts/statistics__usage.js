google.load("visualization", "1", {packages:["corechart"]});

google.setOnLoadCallback(function () {
  setTimeout(drawCharts, 500);
});

function drawCharts() {
  $.ajax({
    url: "/statistics/usage.json",
    dataType:"json",
    async: false,
    success: function(data, status, jqXHR) {
      var unique_all_chart = new google.visualization.LineChart(document.getElementById('usage_unique_all'));
      var unique_all_options = {
        focusTarget: 'category',
        title: 'Completely Unique',
        vAxis: {
          minValue: 0
        },
        legend: {position: 'right'},
        width: 1000, height: 350
      };

      var unique_usersection_chart = new google.visualization.LineChart(document.getElementById('usage_unique_usersection'));
      var unique_usersection_options = {
        focusTarget: 'category',
        title: 'Unique User&Section',
        vAxis: {
          minValue: 0
        },
        legend: {position: 'right'},
        width: 1000, height: 350
      };

      var nonunique_chart = new google.visualization.LineChart(document.getElementById('usage_nonunique'));
      var nonunique_options = {
        focusTarget: 'category',
        title: 'All Uses',
        vAxis: {
          minValue: 0
        },
        legend: {position: 'right'},
        width: 1000, height: 350
      };

      drawChart(data['unique_all'], unique_all_options, unique_all_chart);
      drawChart(data['unique_usersection'], unique_usersection_options, unique_usersection_chart);
      drawChart(data['nonunique'], nonunique_options, nonunique_chart);
    }
  })
}

function drawChart(data, options, chart) {
  data_table = new google.visualization.DataTable();
  data_table.addColumn({
    type: 'date',
    label: 'Date',
    pattern: 'DD MMM yyyy'
  });
  data_table.addColumn({type: 'number', label: 'Payments calculator'});
  data_table.addColumn({type: 'number', label: 'Programme review'});
  data_table.addColumn({type: 'number', label: 'Map members'});
  data_table.addColumn({type: 'number', label: 'Flexi record'});
  data_table.addColumn({type: 'number', label: 'Export flexi record'});
  data_table.addColumn({type: 'number', label: 'Export members'});
  data_table.addColumn({type: 'number', label: 'Export programme meetings'});
  data_table.addColumn({type: 'number', label: 'Export programme activities'});
  data_table.addColumn({type: 'number', label: 'Awarded badges report'});
  data_table.addColumn({type: 'number', label: 'Calendar report'});
  data_table.addColumn({type: 'number', label: 'Due badges report'});
  data_table.addColumn({type: 'number', label: 'Event attendance report'});
  data_table.addColumn({type: 'number', label: 'Missing badge requirements'});
  data_table.addColumn({type: 'number', label: 'Badge Completion Matrix'});

  var our_data = data['data'];
  for(data_row in our_data) {
    row = new Array();
    row[0] = new Date(our_data[data_row]['date']);
    row[1] = our_data[data_row]['OsmMyscoutPaymentsController|calculator'] || 0;
    row[2] = our_data[data_row]['ProgrammeReviewController|balanced'] || 0;
    row[3] = our_data[data_row]['MapMembersController|data'] || 0;
    row[4] = our_data[data_row]['OsmFlexiRecordsController|show' || 0];
    row[5] = our_data[data_row]['OsmExportsController|flexi_record'] || 0;
    row[6] = our_data[data_row]['OsmExportsController|members'] || 0;
    row[7] = our_data[data_row]['OsmExportsController|programme_meetings'] || 0;
    row[8] = our_data[data_row]['OsmExportsController|programme_activities'] || 0;
    row[9] = our_data[data_row]['ReportsController|awarded_badges'] || 0;
    row[10] = our_data[data_row]['ReportsController|calendar'] || 0;
    row[11] = our_data[data_row]['ReportsController|due_badges'] || 0;
    row[12] = our_data[data_row]['ReportsController|event_attendance'] || 0;
    row[13] = our_data[data_row]['ReportsController|missing_badge_requirements'] || 0;
    row[14] = our_data[data_row]['ReportsController|badge_completion_matrix'] || 0;
    data_table.addRow(row);
  }

  var desired_steps = 5;
  options.vAxis.gridlines = {count: graphGridLines(data['max_value'], desired_steps)};
  options.vAxis.maxValue = graphStepSize(data['max_value'], desired_steps) * (options.vAxis.gridlines.count - 1);
  chart.draw(data_table, options);
}
