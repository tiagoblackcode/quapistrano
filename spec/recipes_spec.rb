require 'spec_helper'

describe "Capfile" do
  it "should display all of the tasks when loaded" do
    system "CAPISTRANO_RECIPES='assets unicorn' cap -f #{cap_file}"
  end
end