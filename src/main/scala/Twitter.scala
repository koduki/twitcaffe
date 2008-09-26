import scala.collection.jcl.Conversions.convertList
import scala.collection.jcl.BufferWrapper

import twitter4j.Status
  
object Twitter {
  var twitter:twitter4j.Twitter = null

  def apply(id:String, passwd:String) = {
//    if(twitter == null) {
      twitter = new twitter4j.Twitter(id, passwd)
      twitter.setSource("TwitCaffe")
//    }
    this
  }

  def toXMLContents(statuses:BufferWrapper[Status]) = <Array>{
    for (status <- statuses) yield {
      <status>
      <id>{status.getId}</id>
      <text>{status.getText}</text>
      <createdat>{status.getCreatedAt}</createdat>
      <name>{status.getUser.getName}</name>
      <screenname>{status.getUser.getScreenName}</screenname>
      <image>{status.getUser.getProfileImageURL.toString}</image>
      </status>
    }
  }
  </Array>
  
  def friendsTimeline = toXMLContents( twitter.getFriendsTimeline )
  def replies = toXMLContents( twitter.getReplies )
  def favorites = toXMLContents( twitter.favorites )
  def publicTimeline = toXMLContents( twitter.getPublicTimeline )

  def update(status:String) = twitter.update(status);"<result>update</result>"
  def favorite(id:Int) = twitter.createFavorite(id);"<result>favorite</result>"  

}
