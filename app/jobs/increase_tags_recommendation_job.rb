class IncreaseTagsRecommendationJob < ApplicationJob
  queue_as :default

  def perform(tags_names, user_id)
    return unless tags_names.any?

    user = User.find_by(id: user_id)

    return if user.blank?

    tags_names.uniq!

    redis = RedisSingleton.instance

    key ||= RedisGlobals.user_popular_tags(user_id)

    tags_names.each do |tag|
      redis.zincrby(key, 1, tag)
    end

    GenerateRecommendedCoursesJob.perform_later(user_id)
  end
end
