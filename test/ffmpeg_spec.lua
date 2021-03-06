local ffmpeg = require('ffmpeg')

describe('ffmpeg', function()
  it('should not require Torch', function()
    assert.is_nil(_G.torch)
  end)

  describe('Video', function()
    local video
    local n_video_frames = 418

    before_each(function()
      video = ffmpeg.new('./test/data/centaur_1.mpg')
    end)

    describe(':duration', function()
      it('should return video duration in seconds', function()
        local expected = 14.0
        local actual = video:duration()
        assert.is_near(expected, actual, 1.0)
      end)
    end)

    describe(':pixel_format_name', function()
      it('should return pixel format name as a string', function()
        local expected = 'yuv420p'
        local actual = video:pixel_format_name()
        assert.are.same(expected, actual)
      end)
    end)

    describe(':each_frame', function()
      it('should call callback function once per frame', function()
        local i = 0
        video:each_frame(function() i = i + 1 end)
        assert.are.same(n_video_frames, i)
      end)
    end)

    describe(':read_video_frame', function()
      it('should read first frame successfully', function()
        local ok = pcall(video.read_video_frame, video)
        assert.is_truthy(ok)
      end)

      it('should return error after end of stream is reached', function()
        local ok = true
        for i=0,n_video_frames do
          assert.is_truthy(ok)
          ok = pcall(video.read_video_frame, video)
        end
        assert.is_falsy(ok)
      end)
    end)

    describe(':frame_to_ascii', function()
      it('should convert video frame to an ASCII representation', function()
        local expected = table.concat({
          '                                        ',
          '                                        ',
          '                       .                ',
          '                      .....             ',
          '                     ......             ',
          '                    ......-             ',
          '                    .-.....             ',
          '                   ........             ',
          '                    ........            ',
          '                     .......            ',
          '                      .....             ',
          '                       ...              '
        }, '\n') .. '\n'

        local actual = video
          :filter('gray', 'scale=40:12')
          :read_video_frame()
          :to_ascii()

        assert.are.same(expected, actual)
      end)

      -- it('ascii video fun', function()
      --   local i = 0
      --   io.write('\027[H\027[2J')
      --   video:filter('gray', 'scale=80:24')
      --   video:each_frame(function(frame)
      --     io.write(video:frame_to_ascii(frame))
      --     os.execute('sleep 1')
      --     i = i + 1
      --   end)
      -- end)
    end)
  end)
end)
