#!/usr/bin/env puma

app_dir = '/usr/share/tendrl-api'

directory app_dir

environment 'production'

stdout_redirect "#{app_dir}/log/puma.log", "#{app_dir}/log/error.log", true

threads_count = Integer(ENV['PUMA_MAX_THREADS'] || 8)
threads threads_count, threads_count

bind 'tcp://127.0.0.1:9292'

# === Cluster mode ===

workers Integer(ENV['PUMA_WORKERS'] || 2)

preload_app!

tag 'Tendrl API'

worker_timeout 60

