def cache_clear
    FileUtils.rm_rf(Dir.glob(Rails.root.join('cache/*')))
end