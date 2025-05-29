<<<<<<< HEAD
# FinPro - تطبيق إدارة مالية وتتبع الديون

تطبيق موبايل تم تطويره باستخدام Flutter للواجهة الأمامية و PHP مع MySQL للواجهة الخلفية. يهدف التطبيق إلى مساعدة المستخدمين في إدارة حساباتهم المالية، وتتبع الديون المستحقة لهم أو عليهم تجاه العملاء أو الموردين بسهولة وكفاءة.

## 🌟 الميزات الرئيسية

*   **إدارة العملاء:**
    *   إضافة عملاء جدد (الاسم، رقم الهاتف، العنوان).
    *   عرض قائمة العملاء مع أرصدتهم الحالية وآخر تاريخ تحديث.
    *   تعديل بيانات العملاء الحاليين.
    *   حذف العملاء (مع تأكيد).
*   **إدارة المعاملات:**
    *   تسجيل معاملات مالية لكل عميل (مبالغ له "مدين" أو عليه "دائن").
    *   إضافة تفاصيل للمعاملة (مثل وصف البضاعة، رقم الفاتورة).
    *   تحديد تاريخ المعاملة.
    *   إمكانية إرفاق صورة للمستندات أو الفواتير لكل معاملة.
    *   عرض قائمة بمعاملات كل عميل.
    *   تعديل تفاصيل المعاملات المسجلة.
    *   حذف المعاملات (مع تأكيد وتحديث رصيد العميل تلقائيًا).
*   **تتبع الأرصدة:**
    *   حساب وعرض الرصيد الحالي لكل عميل تلقائيًا.
    *   عرض إجمالي المبالغ "التي لك" (مدين) و "التي عليك" (دائن) على مستوى جميع العملاء في الشاشة الرئيسية.
*   **واجهة مستخدم سهلة:**
    *   واجهة مستخدم بسيطة وواضحة باللغة العربية.
    *   تنقل سهل بين الشاشات المختلفة.
    *   عرض مرئي لحالة الرصيد (أخضر للإيجابي وأحمر للسلبي).

## 💻 التقنيات المستخدمة

*   **الواجهة الأمامية (Frontend):**
    *   Flutter (باستخدام لغة Dart)
    *   `http`: للتواصل مع الـ API الخلفي.
    *   `image_picker`: لاختيار الصور من المعرض أو الكاميرا.
*   **الواجهة الخلفية (Backend):**
    *   PHP
    *   MySQL (لتخزين البيانات)
    *   RESTful API بسيط للتعامل مع طلبات CRUD (إنشاء، قراءة، تحديث، حذف).

## 🚀 الإعداد والتشغيل

لتشغيل هذا المشروع محليًا، ستحتاج إلى إعداد كل من الواجهة الأمامية والخلفية.

### 1. الواجهة الخلفية (PHP & MySQL - مجلد `finpro_api`)

1.  **خادم الويب وقاعدة البيانات:**
    *   تأكد من أن لديك خادم ويب يدعم PHP (مثل XAMPP, MAMP, WAMP, أو خادم Apache/Nginx مستقل) وقاعدة بيانات MySQL مثبتة.
2.  **إنشاء قاعدة البيانات:**
    *   قم بإنشاء قاعدة بيانات جديدة في MySQL بالاسم `finpro_db` (أو أي اسم آخر تفضله، ولكن ستحتاج لتعديل ملف `config.php`).
    *   قم بتنفيذ الأوامر التالية لإنشاء الجداول اللازمة:
        ```sql
        CREATE DATABASE IF NOT EXISTS finpro_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        USE finpro_db;

        CREATE TABLE IF NOT EXISTS `clients` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          `phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
          `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
          `balance` decimal(10,2) DEFAULT 0.00,
          `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
          `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

        CREATE TABLE IF NOT EXISTS `transactions` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `client_id` int(11) NOT NULL,
          `amount` decimal(10,2) NOT NULL,
          `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
          `date` date NOT NULL,
          `type` enum('مدين','دائن') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
          `image_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
          `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
          `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
          PRIMARY KEY (`id`),
          KEY `client_id` (`client_id`),
          CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ```
3.  **نقل ملفات الـ API:**
    *   انسخ محتويات مجلد `finpro_api` (الذي يحتوي على `api.php`, `config.php`, ومجلد `uploads`) إلى مجلد الويب الخاص بخادمك (مثل `htdocs` في XAMPP).
4.  **تكوين الاتصال بقاعدة البيانات:**
    *   افتح ملف `finpro_api/config.php` وقم بتحديث بيانات الاتصال بقاعدة البيانات (`$servername`, `$username`, `$password`, `$dbname`) إذا لزم الأمر.
        ```php
        <?php
        $servername = "localhost"; // أو عنوان خادم قاعدة بياناتك
        $username = "root";        // اسم مستخدم قاعدة البيانات
        $password = "";            // كلمة مرور قاعدة البيانات
        $dbname = "finpro_db";     // اسم قاعدة البيانات

        $conn = new mysqli($servername, $username, $password, $dbname);
        $conn->set_charset("utf8"); // مهم لدعم اللغة العربية

        if ($conn->connect_error) {
            die("فشل الاتصال بقاعدة البيانات: " . $conn->connect_error);
        }
        // لا يوجد ?> في نهاية الملف هنا، لأننا سنقوم بتضمينه فقط
        ?>
        ```
5.  **أذونات مجلد `uploads`:**
    *   تأكد أن خادم الويب لديه صلاحيات الكتابة على مجلد `finpro_api/uploads/`. هذا ضروري لرفع صور المعاملات.
        (مثلاً على Linux: `sudo chmod -R 775 path/to/your/htdocs/finpro_api/uploads` و `sudo chown -R www-data:www-data path/to/your/htdocs/finpro_api/uploads` أو ما يعادلها حسب إعدادات خادمك).

### 2. الواجهة الأمامية (Flutter - مجلد `lib` وما حوله)

1.  **تثبيت Flutter:**
    *   تأكد من أن لديك Flutter SDK مثبتًا ومكوّنًا بشكل صحيح على جهازك.
2.  **استنساخ المستودع (إذا لم تكن قد فعلت ذلك بعد):**
    ```bash
    git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY_NAME.git
    cd YOUR_REPOSITORY_NAME
    ```
3.  **تثبيت الاعتماديات:**
    *   انتقل إلى المجلد الرئيسي لمشروع Flutter في الطرفية ونفذ:
        ```bash
        flutter pub get
        ```
4.  **تحديث عنوان الـ API:**
    *   افتح ملف `lib/services/api_service.dart`.
    *   قم بتحديث قيمة المتغير `baseUrl` ليشير إلى عنوان الـ API الخاص بك الذي قمت بإعداده في الخطوة السابقة.
        *   إذا كنت تختبر على محاكي Android، فإن `10.0.2.2` هو العنوان الصحيح للإشارة إلى `localhost` على جهازك المضيف.
        *   إذا كنت تختبر على جهاز حقيقي متصل بنفس الشبكة، استخدم عنوان IP المحلي لجهاز الكمبيوتر الذي يشغل الخادم (مثال: `http://192.168.1.100/finpro_api/api.php?endpoint=`).
        ```dart
        // lib/services/api_service.dart
        class ApiService {
          // تأكد من تعديل هذا المسار ليتوافق مع إعدادات خادمك
          final String baseUrl = 'http://10.0.2.2/finpro_api/api.php?endpoint=';
          // ... باقي الكود
        }
        ```
5.  **تشغيل التطبيق:**
    *   قم بتوصيل جهاز أو تشغيل محاكي، ثم نفذ:
        ```bash
        flutter run
        ```

## 📸 لقطات شاشة (اختياري)

*(يمكنك إضافة لقطات شاشة لواجهات التطبيق الرئيسية هنا لاحقًا)*

*   مثال:
    *   ![الشاشة الرئيسية](link_to_screenshot_1.png)
    *   ![شاشة تفاصيل العميل](link_to_screenshot_2.png)

## 🤝 المساهمة

نرحب بالمساهمات لتحسين هذا المشروع! إذا كنت ترغب في المساهمة، يرجى اتباع الخطوات التالية:
1.  قم بعمل Fork للمستودع.
2.  أنشئ فرعًا جديدًا لميزاتك (`git checkout -b feature/AmazingFeature`).
3.  قم بعمل Commit لتغييراتك (`git commit -m 'Add some AmazingFeature'`).
4.  قم برفع التغييرات إلى الفرع (`git push origin feature/AmazingFeature`).
5.  افتح طلب سحب (Pull Request).

## 📜 الترخيص

هذا المشروع مرخص بموجب ترخيص MIT - انظر ملف `LICENSE` لمزيد من التفاصيل (إذا أضفت ملف ترخيص).

