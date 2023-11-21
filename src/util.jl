struct TimeKeeper
    start_time_::DateTime
    time_threshold_seconds_::Float16
end

@inline function isTimeOver(time_keeper::TimeKeeper)::Bool
    diff = now() - time_keeper.start_time_  # milliseconds
    return diff.value >= time_keeper.time_threshold_seconds_ * 1000
end
