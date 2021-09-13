# Mixed Reality Spasticity Assessment
Within this repository is my MSc project completed at Imperial College London in Human and Biological Robotics.

The project involved the design, development, and build of a mixed reality app for the Hololens 2. This combined a computer vision solution for angle detection and electromyography (EMG) recording/ communication using a Myo armband for a spasticity medical assessment. The angle of 'catch' and EMG magnitude through the colour of a sphere were displayed in real time to the therapist using the app. All data was sent to a PC where it was saved, stored and optionally live plotted.

To test the efficacy of the assessment system, a study was then carried out on 15 participants. Each participant had 90 passive extensions performed at varying velocities. The angle measurements using the Hololens 2 were compared to a ground truth obtained from a Polhemus electromagnetic sensor. Several factors were then analysed with the conclusion that the app was accurate enough to perform assessments up to 250 deg/s. 

The EMG data of all participants was then analysed in the temporal and frequency domains. The results showed that there was statistical significance between the flexor and extensor muscles of the participants during the healthy stretch reflexes at three velocity bands of slow, medium, and fast.

Overall, the system received very positive clinician feedback and will hopefully move forward to clinical trials.

During assessment as seen through Hololens interface before catch:

![AngleHoloUI](https://user-images.githubusercontent.com/73748574/133106539-a3ae3f38-8d2d-444e-afe7-cf0782f3278b.PNG)

As seen in Hololens when catch occurs:

![AngleHoloUICatch](https://user-images.githubusercontent.com/73748574/133106525-96f036c4-4af3-42d6-a6e5-018e90dd5170.PNG)

Networking protocol:

![NetworkingProtocol](https://user-images.githubusercontent.com/73748574/133106903-c789960f-27ad-4419-8eb1-b6efa13f69d2.png)
