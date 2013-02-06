require 'rubygems'
require 'sinatra'
require 'rack'
require 'digest/md5'
require 'sdbm'
require 'haml'

module Gyazo
  class Controller < Sinatra::Base

    configure do
      set :dbm_path, 'db/id'
      set :image_dir, "public/images/"
      set :send_url, "http://gyazo.kozyty.com/"
      set :image_url, "http://gyazo.kozyty.com/images/"
    end

    get '/' do
      haml :index
    end

    post '/' do
      id   = request[:id]
      data = request[:imagedata][:tempfile].read
      hash = Digest::MD5.hexdigest(data).to_s
      dbm  = SDBM.open(options.dbm_path, 0644)
      dbm[hash] = id
      image_dir = "#{options.image_dir}#{Time.now.strftime("%Y/%m/%d")}"
      image_url = "#{options.image_url}#{Time.now.strftime("%Y/%m/%d")}"
      send_url = "#{options.send_url}#{Time.now.strftime("%Y/%m/%d")}"
      FileUtils.mkdir_p(image_dir) unless FileTest.exist?(image_dir)
      File.open("#{image_dir}/#{hash}.png", 'w'){|f| f.write(data)}

      "#{send_url}/#{hash}"
    end

    get %r{/(\d+\/\d+\/\d+\/\w+)$} do |capture|
      @url = "#{options.send_url}#{capture}"
      @image_url = "#{options.image_url}#{capture}.png"
      haml :image
    end

  end
end
