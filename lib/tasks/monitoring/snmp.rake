desc 'Respond to SNMP requests as a pass_persist script'
namespace :monitoring do
  task :snmp, [:base_oid] => :environment do |_task, args|
    $PROGRAM_NAME = "OSMX #{Rails.env} - SNMP pass_persist Script"

    # Setup cached_Status hash
    cached_status = Cachd::Hash.new(10)
    cached_status.proc_for(:unicorn_workers) { Status.new.unicorn_workers }
    cached_status.proc_for(:cache) { Status.new.cache }
    cached_status.proc_for(:database_size) { Status.new.database_size }
    cached_status.proc_for(:users) { Status.new.users }
    cached_status.proc_for(:sessions) { Status.new.sessions }

    # Setup script
    script = SNMPPass::Script::PassPersist.new
    script.variable_store.add_list(args[:base_oid], {
      '1.1'   => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:unicorn_workers] }),
      '2.1'   => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:cache][:ram_max] }),
      '2.2'   => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:cache][:ram_used] }),
      '2.3'   => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:cache][:keys] }),
      '2.4'   => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:cache][:cache_hits] }),
      '2.4.0' => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:cache][:cache_hits] }),
      '2.4.1' => SNMPPass::Variable::Gauge.new(getter: proc { (cached_status[:cache][:cache_hits_percent] * 100).to_i }),
      '2.5'   => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:cache][:cache_misses] }),
      '2.5.0' => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:cache][:cache_misses] }),
      '2.5.1' => SNMPPass::Variable::Gauge.new(getter: proc { (cached_status[:cache][:cache_misses_percent] * 100).to_i }),
      '2.6'   => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:cache][:cache_attempts] }),
      '3.0'   => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:users][:total] }),
      '3.1'   => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:users][:unactivated] }),
      '3.2'   => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:users][:activated] }),
      '3.3'   => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:users][:connected] }),
      '4.1.0' => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:sessions][:totals][:all] }),
      '4.1.1' => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:sessions][:totals][:users] }),
      '4.1.2' => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:sessions][:totals][:guests] }),
      '4.2.0' => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:sessions][:average_ages][:all] }),
      '4.2.1' => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:sessions][:average_ages][:users] }),
      '4.2.2' => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:sessions][:average_ages][:guests] }),
      '4.3.0' => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:sessions][:average_durations][:all] }),
      '4.3.1' => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:sessions][:average_durations][:users] }),
      '4.3.2' => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:sessions][:average_durations][:guests] }),
      '5.1.0' => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:database_size][:totals][:count] }),
      '5.2.0' => SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:database_size][:totals][:size] }),
    })
    database_data = cached_status[:database_size][:tables].map.with_index{ |table, index| [
      SNMPPass::Variable::String.new(getter: proc { cached_status[:database_size][:tables][index][:model]}),
      SNMPPass::Variable::String.new(getter: proc { cached_status[:database_size][:tables][index][:table]}),
      SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:database_size][:tables][index][:count]}),
      SNMPPass::Variable::Gauge.new(getter: proc { cached_status[:database_size][:tables][index][:size]}),
    ] }
    script.variable_store.add_table("#{args[:base_oid]}.6", database_data)

    # Run script
    script.send(:run_once) if Rails.env.test?
    script.run unless Rails.env.test?
  end # task
end # namespeace
