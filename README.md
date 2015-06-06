# quiz_editor1
A quiz editor back-end that allows to prepare quiz tests and run the test for testing purpose. Stores quiz questions in plain text.

Quiz Editor
-----------------
This quiz editor is excellent for preparing quick quizes for personal or other use. Easy syntax would make it possible to create any test interface if necessary.

This is a quiz editor written in Lazarus+Free Pascal using Object Pascal capabilities. It uses LCL for GUI.

The editor basically lets you edit plain text quiz data that stores each Question and its possible answers in each line. Example:

	What color is Apple? = |Yellow| *Red|Blue
	Where is the Sky? = |Beneath us|Front of us|Under the land| *Up
	Are you a human?! = | *Yes|No
	End of quiz = | | | |*


As you can see a question can have multiple answers. The number of answers may vary on different questions.

The program has a Run Test feature where you can simulate the test. You can also have debugging information to test the status with answering every question. It has a cheat option to show you correct answer that can aid in testing.

Actually Anette asked me for help on writing such an editor. She already had the "reader" for the quiz. I had some spare time and started writing it my way.

I have only compiled it under Windows. But other supported platforms (linux, mac os, raspbian etc.) should also be compilable.

The source code of this project is released under Creative Commons Attribution-ShareAlike (CC BY-SA) license.