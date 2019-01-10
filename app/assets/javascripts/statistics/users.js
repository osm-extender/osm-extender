google.load("visualization", "1", {packages:["corechart"]});

google.setOnLoadCallback(function () {
  setTimeout(drawCharts, 500);
});

function drawCharts() {
  $.ajax({
    url: 'users.json',
    dataType:"json",
    async: false,
    success: function(data, status, jqXHR) {
      var users_chart = new google.visualization.LineChart(document.getElementById('users_chart'));
      var users_options = {
        focusTarget: 'category',
        title: 'Number of Registered Accounts',
        vAxis: {
          minValue: 0
        },
        legend: {position: 'none'},
        width: 1000, height: 350
      };

      drawUsersChart(data, users_options, users_chart);
    }
  })
}

function drawChart(data_table, max_value, options, chart) {
  var desired_steps = 5;
  options.vAxis.gridlines = {count: graphGridLines(max_value, desired_steps)};
  options.vAxis.maxValue = graphStepSize(max_value, desired_steps) * (options.vAxis.gridlines.count - 1);
  chart.draw(data_table, options);
}

function drawUsersChart(data, options, chart) {
  data_table = new google.visualization.DataTable();
  data_table.addColumn({
    type: 'date',
    label: 'Date',
    pattern: 'DD MMM yyyy'
  });
  data_table.addColumn({
    type: 'number',
    label: 'Users'
  });

  var users_data = data['data'];
  for(data_row in users_data) {
    row = users_data[data_row];
    row[0] = new Date(row[0]);
    data_table.addRow(row);
  }

  drawChart(data_table, data['max_value'], options, chart);
}
