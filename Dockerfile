# เปลี่ยนจาก Alpine เป็นรุ่นปกติ (Ubuntu-based) ที่รองรับชิป ARM64 ของ Mac M4
FROM eclipse-temurin:17-jre

# สร้างโฟลเดอร์สำหรับทำงานข้างใน Docker
WORKDIR /app

# ก๊อปปี้ไฟล์ .jar ที่ได้จากการใช้คำสั่ง Maven Build มาใส่ใน Docker
COPY target/*.jar app.jar

# บอกให้รู้ว่าแอปนี้เปิดประตูพอร์ต 8080 ไว้นะ
EXPOSE 8080

# คำสั่งตอนสั่งรัน Container ให้มัน Start Spring Boot
CMD ["java", "-jar", "app.jar"]