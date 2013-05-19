require 'coveralls/rake/task'
Coveralls::RakeTask.new

MiniTest::Rails::Testing.default_tasks << 'modules'

task test_with_coveralls: [:minitest, 'coveralls:push']
task default: :test_with_coveralls
