pipeline {
    agent any

    stages {
        // ด่านที่ 1: แวะตรวจโค้ดก่อน (Unit Test)
        stage('1. Unit Test (QC Code)') {
            steps {
                echo '🧪 กำลังรัน Unit Test เพื่อตรวจสอบความถูกต้องของลอจิก...'
                sh 'chmod +x mvnw'
                sh './mvnw test'
            }
        }

        // ด่านที่ 2: ประกอบร่างแอป (Build JAR)
        stage('2. Build JAR') {
            steps {
                echo '🚀 กำลัง Build โค้ด Spring Boot (สร้างไฟล์ .jar)...'
                // ด่านนี้เราข้ามเทสต์ไปเลย เพราะเทสต์ผ่านจากด่าน 1 มาแล้ว
                sh './mvnw clean package -DskipTests'
            }
        }

        // ด่านที่ 3: แพ็กใส่กล่อง (Build Docker Image)
        stage('3. Build Docker Image') {
            steps {
                echo '📦 กำลังเอาไฟล์ .jar ยัดใส่ Docker Image...'
                sh 'docker build -t springboot-api:latest .'
            }
        }

        // ด่านที่ 4: ไรเดอร์เอาของไปส่ง (Deploy)
        stage('4. Deploy to VM-2 & VM-3') {
            steps {
                echo '🚚 กำลังเซฟ Image และส่งไปรันที่ VM-2 และ VM-3...'
                sh 'docker save -o springboot-api.tar springboot-api:latest'

                script {
                    def servers = ['192.168.64.3', '192.168.64.4']
                    for (ip in servers) {
                        echo "======================================"
                        echo "🚀 กำลัง Deploy ไปที่เครื่อง ${ip}..."
                        echo "======================================"

                        // 1. โยนไฟล์
                        sh "sshpass -p 'yorchgeorge' scp -o StrictHostKeyChecking=no springboot-api.tar yorch@${ip}:/home/yorch/"

                        // 2. สั่งรัน
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