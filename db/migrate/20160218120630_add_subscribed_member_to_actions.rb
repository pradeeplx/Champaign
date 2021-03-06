# frozen_string_literal: true
class AddSubscribedMemberToActions < ActiveRecord::Migration
  def change
    add_column :actions, :subscribed_member, :boolean, default: true
  end
end
