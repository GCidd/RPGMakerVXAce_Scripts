# forum link: http://www.rpgmakercentral.com/topic/41173-change-actors-faceset-on-status-screen/
# Script that loads different graphic for actor in the status menu.
# Graphic is loaded from Graphics/Faces/ folder as {actor_name}_status.png
# If the graphic is larger (or smaller) than 96x96 it is stretched.
#
# -------------------
# Script by: vFoggy

class Window_Status < Window_Selectable
    def draw_status_face(status_name, x, y, enabled = true)
      bitmap = Bitmap.new(status_name)
      src_rect = Rect.new(0, 0, bitmap.width, bitmap.height)
      dst_rect = Rect.new(x, y, 96, 96)
      contents.stretch_blt(dst_rect, bitmap, src_rect, enabled ? 255 : translucent_alpha)
      bitmap.dispose
    end
    
    def draw_actor_face(actor, x, y, enabled = true)
      status_file_name = "Graphics/Faces/#{actor.name}_status.png"
      if File.file?(status_file_name)
        draw_status_face(status_file_name, x, y, enabled)
      else
        draw_face(actor.face_name, actor.face_index, x, y, enabled)
      end
    end
  end