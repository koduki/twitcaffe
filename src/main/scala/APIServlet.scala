import javax.servlet._
import javax.servlet.http._

import twitter4j.Status
  
class APIServlet extends HttpServlet {
  override def doGet(req: HttpServletRequest, res: HttpServletResponse) {
    val id = req.getParameter("id")
    val passwd = req.getParameter("passwd")
    val action = req.getRequestURI().split("/")(2)
    
    val contents = action match{
      case "update" => val status = req.getParameter("status"); Twitter(id, passwd).update(status)
      case "favorite" =>  val tid = req.getParameter("twitter_id").toInt; Twitter(id, passwd).favorite( tid )
      case "timeline" => Twitter(id, passwd).friendsTimeline
      case "replies" => Twitter(id, passwd).replies
      case "favorites" => Twitter(id, passwd).favorites      
    }
    
    res.setContentType("text/xml; charset=utf-8")
    res.getWriter.print(contents)
  }
}
