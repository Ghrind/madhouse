require_relative "madhouse/version"
require 'pstore'
require 'fileutils'

module Madhouse
  def self.load(namespace)
    DataFile.new(namespace).content
  end

  def self.secure(namespace)
    location = DataFile.new(namespace).location
    File.chmod(0600, location)
  end

  def self.save(namespace, data)
    data_file = DataFile.new(namespace)
    create(namespace) unless data_file.exist?
    data_file.update data
  end

  def self.create(namespace)
    location = DataFile.new(namespace).location
    FileUtils.mkdir_p(File.dirname(location))
  end

  class DataFile
    DEFAULT_FILENAME = 'data.pstore'
    DATA_ROOT = 'root'

    def initialize(namespace)
      @namespace = namespace
    end

    def location
      File.expand_path(File.join('~', ".#{@namespace}", DEFAULT_FILENAME))
    end

    def content
      return unless exist?
      store.transaction(true) do
        store[DATA_ROOT]
      end
    end

    def update(data)
      store.transaction do
        store[DATA_ROOT] = data
      end
    end

    def exist?
      File.exist?(location)
    end

    private

    def store
      @_store ||= PStore.new(location)
    end
  end
end
