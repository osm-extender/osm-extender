google.load("visualization", "1", {packages:["corechart"]});

google.setOnLoadCallback(function () {
  setTimeout(drawCharts, 500);
});

function drawCharts() {
  $.ajax({
    url: "/statistics/users.json",
    dataType:"json",
    async: false,
    success: function(data, status, jqXHR) {
      var users_chart = new google.visualization.LineChart(document.getElementById('users_chart'));

      var users_options = {
        focusTarget: 'category',
        vAxis: {
          maxValue: data['users']['max_value'],
          minValue: 0,
          gridlines: {
            count: ((data['users']['max_value'] + 1) / 2) + 1,
          }
        },
        legend: {position: 'none'},
        width: 750, height: 350
      };

      drawChart(data['users']['data'], users_options, users_chart);
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
  data_table.addColumn({
    type: 'number',
    label: 'Users'
  });

  for(data_row in data) {
    row = new Array();
    row[0] = new Date(data[data_row]['date']);
    row[1] = data[data_row]['total'];
    data_table.addRow(row);
  }

  chart.draw(data_table, options);
}
