# frozen_string_literal: true

# name: discourse-admin-only
# about: Adds an "Admin Only" checkbox to topics
# version: 1.0
# authors: Pushpinder
# url: https://github.com/pushpinder6805/discourse-admin-only

enabled_site_setting :topic_custom_field_enabled
register_asset "stylesheets/common.scss"

after_initialize do
  module ::AdminOnlyCustomField
    FIELD_NAME = "admin_only"
    FIELD_TYPE = "boolean"
  end

  register_topic_custom_field_type(
    AdminOnlyCustomField::FIELD_NAME,
    AdminOnlyCustomField::FIELD_TYPE.to_sym
  )

  add_to_class(:topic, AdminOnlyCustomField::FIELD_NAME.to_sym) do
    custom_fields[AdminOnlyCustomField::FIELD_NAME]
  end

  add_to_class(:topic, "#{AdminOnlyCustomField::FIELD_NAME}=") do |value|
    custom_fields[AdminOnlyCustomField::FIELD_NAME] = value
  end

  on(:topic_created) do |topic, opts, user|
    topic.send(
      "#{AdminOnlyCustomField::FIELD_NAME}=".to_sym,
      opts[AdminOnlyCustomField::FIELD_NAME.to_sym]
    )
    topic.save!
  end

  PostRevisor.track_topic_field(AdminOnlyCustomField::FIELD_NAME.to_sym) do |tc, value|
    tc.record_change(
      AdminOnlyCustomField::FIELD_NAME,
      tc.topic.send(AdminOnlyCustomField::FIELD_NAME),
      value
    )
    tc.topic.send("#{AdminOnlyCustomField::FIELD_NAME}=".to_sym, value.present? ? value : nil)
  end

  add_to_serializer(:topic_view, AdminOnlyCustomField::FIELD_NAME.to_sym) do
    object.topic.send(AdminOnlyCustomField::FIELD_NAME)
  end

  add_preloaded_topic_list_custom_field(AdminOnlyCustomField::FIELD_NAME)

  add_to_serializer(:topic_list_item, AdminOnlyCustomField::FIELD_NAME.to_sym) do
    object.send(AdminOnlyCustomField::FIELD_NAME)
  end
end
