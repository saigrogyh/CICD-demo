pipeline {
    agent any

    stages {
        stage('1. Build JAR') {
            steps {
                echo '🚀 กำลัง Build โค้ด Spring Boot (สร้างไฟล์ .jar)...'
                sh 'chmod +x mvnw'
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('2. Build Docker Image') {
            steps {
                echo '📦 กำลังเอาไฟล์ .jar ยัดใส่ Docker Image...'
                sh 'docker build -t springboot-api:latest .'
            }
        }

        stage('3. Deploy to VM-2 & VM-3') {
            steps {
                echo '🚚 กำลังเซฟ Image และส่งไปรันที่ VM-2 และ VM-3...'

                // แปลง Docker Image เป็นไฟล์ .tar เพื่อให้ส่งข้ามเครื่องได้ง่ายๆ
                sh 'docker save -o springboot-api.tar springboot-api:latest'

                script {
                    // รายชื่อ IP ของลูกค้าที่เราจะเอาของไปส่ง
                    def servers = ['192.168.64.3', '192.168.64.4']

                    for (ip in servers) {
                        echo "======================================"
                        echo "🚀 กำลัง Deploy ไปที่เครื่อง ${ip}..."
                        echo "======================================"

                        // 1. ไรเดอร์โยนไฟล์ .tar ข้ามเครื่องไปที่ VM-2 และ VM-3
                        sh "sshpass -p 'yorchgeorge' scp -o StrictHostKeyChecking=no springboot-api.tar yorch@${ip}:/home/yorch/"

                        // 2. ไรเดอร์ไขกุญแจเข้าบ้านไปสั่งรัน Docker ให้ทำงาน!
                        // (ใส่ echo yorchgeorge | sudo -S ไว้เผื่อเครื่องปลายทางบังคับใส่รหัสแอดมินตอนรัน docker)
                        sh """
                        sshpass -p 'yorchgeorge' ssh -o StrictHostKeyChecking=no yorch@${ip} '
                            echo yorchgeorge | sudo -S docker load -i /home/yorch/springboot-api.tar &&
                            echo yorchgeorge | sudo -S docker stop springboot-api || true &&
                            echo yorchgeorge | sudo -S docker rm springboot-api || true &&
                            echo yorchgeorge | sudo -S docker run -d -p 8080:8080 --name springboot-api springboot-api:latest
                        '
                        """
                    }
                }
            }
        }
    }
}