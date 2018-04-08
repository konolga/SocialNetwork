------------------------------------------------------------------------------------
-------------------------------QUERIES----------------------------------------------

USE SocialNetwork

------------------------------------------------------------------------------------
--1. Show User’s News Feed-------------------------------------------------------------
--Display the list of posts that should be seen on the news feed page (All my Friend posts).
-- Choose the connected user and Order the posts by posted date. (Specific user)
declare @SpecificUserID int = 11
select  DateOfPublish, nu.UserFirstName+ ' '+ nu.UserLastName FriendName, 'added picture' Action, '-' Description, pic.PictureURL
from Publish pub join Picture pic on  pic.PictureID = pub.PublishID
	 join NetworkUsers nu on nu.UserID=pub.UserID
where pub.UserID in (select UserID2
					 from Friendship f join NetworkUsers n on n.UserID=f.UserID2
					 where UserID1=@SpecificUserID)
	 and pic.PictureType='no'

union

select pub.DateOfPublish, nu.UserFirstName+ ' '+ nu.UserLastName, 'added  new post' Action, pos.PostText, pic.PictureURL
from NetworkUsers nu join Publish pub on nu.UserID=pub.UserID
	 join Post pos on  pos.PostID = pub.PublishID
	 left join Picture pic on  pic.PictureID = pos.PictureID
	  
where pub.UserID in (select UserID2
					 from Friendship f join NetworkUsers n on n.UserID=f.UserID2
					 where UserID1=@SpecificUserID)


union

select pub.DateOfPublish, nu.UserFirstName+ ' '+ nu.UserLastName, 'added' +str(count(pic.PictureURL)) + ' pictures to the album' Action, 'Name: ' + alb.AlbumName +  '. Description: ' + alb.AlbumDescription, ''
from Publish pub join Album alb on pub.PublishID=alb.AlbumID
	join AlbumPictures ap on ap.AlbumID=alb.AlbumID
	join Picture pic on pic.PictureID=ap.PictureID
	join NetworkUsers nu on nu.UserID=pub.UserID
where pub.UserID in (select UserID2
					 from Friendship f join NetworkUsers n on n.UserID=f.UserID2
					 where UserID1=@SpecificUserID)
	 and ap.PictureType='al'
group by pub.DateOfPublish,nu.UserFirstName,nu.UserLastName, pub.PublishType, alb.AlbumName, alb.AlbumDescription 
order by pub.DateOfPublish desc



------------------------------------------------------------------------------------
--2. Show Users in my groups
--Display users who belong to at least three groups that I belong to. (Specific user)
------------------------------------------------------------------------------------
declare @SpecificUserID2 int = 20

SELECT g.UserID, n.UserLastName+' '+n.UserFirstName UserInMyGroup
FROM dbo.GroupMembership g JOIN dbo.NetworkUsers n ON g.UserID=n.UserID
WHERE GroupID IN (SELECT GroupID
				  FROM dbo.GroupMembership
				  WHERE UserID=@SpecificUserID2)
GROUP BY g.UserID, n.UserFirstName, n.UserLastName
HAVING COUNT(GroupID)>=3 AND g.userID<>@SpecificUserID2


------------------------------------------------------------------------------------
--3. What are the Highlight posts?
--Display posts order by number of likes (order them from the most liked),
-- don’t show posts that has no likes at all.
------------------------------------------------------------------------------------
SELECT  po.PostText, pi.PictureURL, COUNT(l.PublishID) NumberOfLikes
FROM dbo.Likes l JOIN dbo.Publish p ON l.PublishID=p.PublishID
	JOIN dbo.Post po ON po.PostID=p.PublishID
	JOIN dbo.Picture pi ON pi.PictureID=po.PictureID AND pi.PictureType=po.PictureType
GROUP BY po.PostID, po.PostText, pi.PictureURL, po.PostText, l.PublishID
ORDER BY COUNT(l.PublishID) desc

------------------------------------------------------------------------------------
--4. Users I may know
--Suggest me users which are not my friends but we have many friends in common.
-- Order them by amount of mutual friends. (Specific user)
------------------------------------------------------------------------------------
DECLARE @SpecificUserID3 INT = 12

SELECT n.UserFirstName+' '+n.UserLastName YouMayKnow, COUNT(UserID2) NumberOfMitualFriends
FROM dbo.Friendship f JOIN dbo.NetworkUsers n ON n.UserID = f.UserID2
WHERE UserID1 IN 
				(--list of MyFriends
				SELECT UserID2 
				FROM dbo.Friendship
				WHERE UserID1=@SpecificUserID3
				)
GROUP BY UserID2, n.UserFirstName, n.UserLastName
ORDER BY COUNT(UserID2) desc


------------------------------------------------------------------------------------
--5. Best Friend
--For user display the best friend. Best Friend is the one 
--who sent me the maximum messages and he likes at least 5 of my Posts.
------------------------------------------------------------------------------------
DECLARE @SpecificUserID4 INT = 11;
WITH FriendMaxMsg AS 
(
SELECT SenderID FriendMaxMsg
FROM dbo.UserMessages
GROUP BY SenderID, ReceiverID
HAVING ReceiverID=@SpecificUserID4 
		--check that sender of max msgs is really friend
		AND SenderID IN (SELECT UserID2 
						from dbo.Friendship
						WHERE UserID1=@SpecificUserID4)
		--find who sent me the maximum messages 
		AND COUNT(SenderID) in (SELECT MAX(NumberOfMessages) 
							 FROM   (
									SELECT SenderID , COUNT(SenderID) NumberOfMessages
									FROM dbo.UserMessages 
									WHERE ReceiverID=@SpecificUserID4 
									GROUP BY SenderID ) MessagesFromFriends
									)
),
Friends5Likes AS
(
SELECT COUNT(l.UserID) NumberOfLikes, l.UserID UserIDWithMostLikes
FROM dbo.Likes l JOIN Publish p ON p.PublishID = l.PublishID
WHERE p.UserID=@SpecificUserID4
GROUP BY  l.UserID
HAVING COUNT(l.UserID)>=5
)

SELECT m.FriendMaxMsg BestFriendID
FROM FriendMaxMsg m JOIN Friends5Likes l ON m.FriendMaxMsg=l.UserIDWithMostLikes

------------------------------------------------------------------------------------
--6. Portrait
---Display list of pictures which I am the only person who tagged on. 
------------------------------------------------------------------------------------
DECLARE @SpecificUserID5 INT = 12;
WITH PicturesWithOneTagOnly AS
(
SELECT PictureID
FROM dbo.Tags
GROUP BY PictureID
HAVING count (UserID) = 1
),

PicturesWhereSpecificUserTaged AS
(
SELECT PictureID
FROM dbo.Tags
WHERE UserID=@SpecificUserID5
GROUP BY PictureID
)

SELECT o.PictureID, p.PictureURL
FROM PicturesWithOneTagOnly o JOIN PicturesWhereSpecificUserTaged u ON u.PictureID = o.PictureID
	JOIN dbo.Picture p ON p.PictureID=u.PictureID

------------------------------------------------------------------------------------
--7. Administrator Statistics
--Display the Usage of the website components per year. How many posts were written, 
--how many pictures and Albums were uploaded. Order the Result by year. 
------------------------------------------------------------------------------------
SELECT YEAR(DateOfPublish) Year, PublishType, count (PublishID)
FROM publish 
GROUP BY YEAR(DateOfPublish), PublishType
ORDER BY YEAR(DateOfPublish)


------------------------------------------------------------------------------------
--8. We like our picture
--Display pictures which all the users tagged on it, like it. 
--FOR example, Tom, Danni and Avi were tagged on a picture which the three of them 
--liked will be returned from the query.
------------------------------------------------------------------------------------
SELECT t.PictureID, COUNT(l.UserID) NumOfLikesByTaged, COUNT(t.UserID) NumOfTaged
FROM dbo.Likes l right OUTER JOIN tags t ON t.UserID = l.UserID AND t.PictureID=l.PublishID
GROUP BY t.PictureID
HAVING  COUNT(l.UserID) = COUNT(t.UserID)
ORDER BY t.PictureID DESC
