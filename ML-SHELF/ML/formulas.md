# รวมสูตร Machine Learning

ไฟล์นี้รวมสูตรที่ใช้ในบทเรียนทั้งหมดไว้สำหรับค้นหา ไม่จำเป็นต้องจำทุกสูตร ให้ดูว่า **สูตรรับค่าอะไร คำนวณอย่างไร และผลลัพธ์หมายถึงอะไร**

## 1. สัญลักษณ์ที่พบบ่อย

| สัญลักษณ์ | ความหมาย |
|---|---|
| $n$ | จำนวนข้อมูลทั้งหมด |
| $p$ | จำนวน Features |
| $K$ | จำนวนคลาสหรือจำนวน Folds ตามบริบท |
| $T$, $M$ | จำนวนต้นไม้หรือจำนวนรอบของโมเดล |
| $i,j,k,t$ | ตัวนับลำดับข้อมูล Feature คลาส หรือต้นไม้ |
| $x_i$ | ค่า Feature ของข้อมูลลำดับที่ $i$ |
| $y_i$, $\hat{y}_i$ | Target จริงและค่าทำนายของข้อมูลลำดับที่ $i$ |
| $\bar{y}$ | ค่าเฉลี่ยของ Target จริง |
| $p_i$ | ความน่าจะเป็นของข้อมูลลำดับที่ $i$ |
| $\mu$, $\sigma$ | ค่าเฉลี่ยและส่วนเบี่ยงเบนมาตรฐาน |
| $w$, $b$ | Weight และ Bias |
| $\lambda$, $\alpha$ | ความแรงของ Regularization |
| $\eta$ | Learning rate |

เครื่องหมาย $\sum$ หมายถึงนำค่าตามช่วงมาบวกกัน:

$$
\sum_{i=1}^{3}x_i=x_1+x_2+x_3
$$

## 2. ค่าเฉลี่ยและ StandardScaler

ค่าเฉลี่ย:

$$
\bar{x}=\frac{1}{n}\sum_{i=1}^{n}x_i
$$

`StandardScaler` ใช้ส่วนเบี่ยงเบนมาตรฐานแบบประชากร หรือ `ddof=0`:

$$
\sigma=\sqrt{\frac{1}{n}\sum_{i=1}^{n}(x_i-\mu)^2}
$$

Z-score:

$$
z=\frac{x-\mu}{\sigma}
$$

$z$ บอกว่าค่า $x$ อยู่ห่างจากค่าเฉลี่ยกี่เท่าของส่วนเบี่ยงเบนมาตรฐาน ต้องหา $\mu$ และ $\sigma$ จาก Train เท่านั้น แล้วใช้ค่าเดิมแปลง Validation และ Test เพื่อป้องกัน Data Leakage

### สูตรตรวจ Outliers ด้วย IQR

$$
\mathrm{IQR}=Q_3-Q_1
$$

$$
\mathrm{Lower}=Q_1-1.5\times\mathrm{IQR}
$$

$$
\mathrm{Upper}=Q_3+1.5\times\mathrm{IQR}
$$

ค่าที่อยู่นอกช่วง Lower ถึง Upper จะถูกระบุเป็น Outlier เบื้องต้น ส่วน Z-score ใช้สูตรเดียวกับด้านบนและมักตรวจค่าที่ $|z|>3$ ทั้งสองเกณฑ์ใช้เพื่อค้นหาค่าที่ควรตรวจเพิ่ม ไม่ได้ยืนยันว่าข้อมูลนั้นผิด

### Probability และ Statistics

Population variance, sample variance และ standard error ของค่าเฉลี่ย:

$$
\sigma^2=\frac{1}{N}\sum_{i=1}^{N}(x_i-\mu)^2
$$

$$
s^2=\frac{1}{n-1}\sum_{i=1}^{n}(x_i-\bar{x})^2
$$

$$
SE_{\bar{x}}=\frac{s}{\sqrt{n}}
$$

Conditional probability และกฎของ Bayes:

$$
P(A\mid B)=\frac{P(A\cap B)}{P(B)}
$$

$$
P(A\mid B)=\frac{P(B\mid A)P(A)}{P(B)}
$$

Pearson correlation:

$$
r=\frac{\sum_{i=1}^{n}(x_i-\bar{x})(y_i-\bar{y})}
{\sqrt{\sum_{i=1}^{n}(x_i-\bar{x})^2}
\sqrt{\sum_{i=1}^{n}(y_i-\bar{y})^2}}
$$

### MinMaxScaler

ปรับ Feature ให้อยู่ในช่วง `0–1`:

$$
x' = \frac{x - x_{\min}}{x_{\max} - x_{\min}}
$$

### RobustScaler

ใช้ Median และ IQR จึงทนต่อ Outliers มากกว่า:

$$
x' = \frac{x - \operatorname{Median}(x)}{Q_3 - Q_1}
$$

โดย $Q_1$ คือควอไทล์ที่ 1 และ $Q_3$ คือควอไทล์ที่ 3

### MaxAbsScaler

หารด้วยค่าสัมบูรณ์ที่มากที่สุดของ Feature:

$$
x' = \frac{x}{\max(|x|)}
$$

### L1 และ L2 Normalization

สำหรับข้อมูลหนึ่งแถว $\mathbf{x}=(x_1,\ldots,x_p)$:

$$
\|\mathbf{x}\|_1 = \sum_{j=1}^{p}|x_j|
$$

$$
\|\mathbf{x}\|_2 = \sqrt{\sum_{j=1}^{p}x_j^2}
$$

จากนั้นปรับแถวด้วย:

$$
\mathbf{x}' = \frac{\mathbf{x}}{\|\mathbf{x}\|}
$$

ดูคำอธิบายและตัวอย่างโค้ดที่ [Scaling และ Normalization](scaling-normalization.md)

## 3. การแบ่งข้อมูลและ Cross-validation

ถ้ามีข้อมูล $n$ แถวและกำหนด `test_size=r`:

$$
n_{\text{test}}\approx n\times r,qquad
n_{\text{train}}=n-n_{\text{test}}
$$

คะแนนเฉลี่ยจาก $K$ Folds:

$$
\bar{s}=\frac{1}{K}\sum_{k=1}^{K}s_k
$$

ส่วนเบี่ยงเบนมาตรฐานของคะแนน:

$$
\sigma_s=\sqrt{\frac{1}{K}\sum_{k=1}^{K}(s_k-\bar{s})^2}
$$

จำนวนแถว Validation ต่อ Fold โดยประมาณ:

$$
n_{\text{validation per fold}}\approx\frac{n}{K}
$$

## 4. Hyperparameter tuning

### Optimization

Gradient รวมความชันของพารามิเตอร์ทุกตัว:

$$
\nabla J(w)=
\left[
\frac{\partial J}{\partial w_1},\ldots,
\frac{\partial J}{\partial w_p}
\right]
$$

Gradient descent เดินไปทิศตรงข้ามกับ Gradient:

$$
w\leftarrow w-\eta\nabla J(w)
$$

$\eta$ คือ Learning rate ส่วน Deep Learning ใช้ Backpropagation และ Chain rule เพื่อหา Gradient ของแต่ละชั้น:

$$
\frac{\partial L}{\partial W^{(l)}}
=\frac{\partial L}{\partial a^{(l)}}
\frac{\partial a^{(l)}}{\partial z^{(l)}}
\frac{\partial z^{(l)}}{\partial W^{(l)}}
$$

สำหรับ Metric แบบ Error ซึ่งค่ายิ่งต่ำยิ่งดี Generalization gap คือ:

$$
\mathrm{Gap}_{\text{error}}
=\mathrm{Validation\ Error}
-\mathrm{Train\ Error}
$$

สำหรับ Metric แบบคะแนนซึ่งค่ายิ่งสูงยิ่งดี:

$$
\mathrm{Gap}_{\text{score}}
=\mathrm{Train\ Score}
-\mathrm{Validation\ Score}
$$

Gap สูงอาจบ่งชี้ Overfitting แต่ต้องดูระดับคะแนนด้วย หาก Train และ Validation แย่ทั้งคู่ โมเดลอาจ Underfitting

ถ้าแต่ละพารามิเตอร์มีตัวเลือก $a_1,a_2,\ldots,a_m$:

$$
\text{Combinations}=\prod_{j=1}^{m}a_j
$$

$$
\text{Grid Search fits}=\text{Combinations}\times K
$$

$$
\text{Randomized Search fits}=n_{\text{iter}}\times K
$$

เมื่อ `refit=True` อาจฝึกเพิ่มอีก 1 ครั้งด้วยพารามิเตอร์ที่ดีที่สุด

## 5. Linear Regression

Feature เดียว:

$$
\hat{y}=wx+b
$$

หลาย Features:

$$
\hat{y}=b+w_1x_1+w_2x_2+\cdots+w_px_p
$$

Residual และผลรวมความคลาดเคลื่อนกำลังสอง:

$$
e_i=y_i-\hat{y}_i
$$

$$
\mathrm{SSE}=\sum_{i=1}^{n}(y_i-\hat{y}_i)^2
$$

Linear Regression เลือก weights และ bias ที่ทำให้ SSE ต่ำที่สุด

## 6. Metrics สำหรับ Regression

### MAE

$$
\mathrm{MAE}=\frac{1}{n}\sum_{i=1}^{n}|y_i-\hat{y}_i|
$$

MAE คือความผิดพลาดเฉลี่ย มีหน่วยเดียวกับ Target

### MSE และ RMSE

$$
\mathrm{MSE}=\frac{1}{n}\sum_{i=1}^{n}(y_i-\hat{y}_i)^2
$$

วิธีคิดคือ **หาผลต่าง → ยกกำลังสอง → รวม → หารด้วยจำนวนข้อมูล** จึงให้น้ำหนักกับความผิดพลาดขนาดใหญ่มากขึ้น

$$
\mathrm{RMSE}=\sqrt{\mathrm{MSE}}
$$

RMSE กลับมาเป็นหน่วยเดียวกับ Target

### MAPE

$$
\mathrm{MAPE}=\frac{100}{n}\sum_{i=1}^{n}
\left|\frac{y_i-\hat{y}_i}{y_i}\right|
$$

MAPE แสดงเป็นเปอร์เซ็นต์ แต่ใช้ไม่ได้ตรง ๆ เมื่อ $y_i=0$ และอาจสูงผิดปกติเมื่อ $y_i$ ใกล้ศูนย์

### $R^2$

$$
R^2=1-
\frac{\sum_{i=1}^{n}(y_i-\hat{y}_i)^2}
{\sum_{i=1}^{n}(y_i-\bar{y})^2}
$$

- $R^2=1$: ทำนายตรงทั้งหมดในข้อมูลชุดนั้น
- $R^2=0$: พอ ๆ กับการทายค่าเฉลี่ย
- $R^2<0$: แย่กว่าการทายค่าเฉลี่ย

## 7. Ridge Regression

Ridge เพิ่มโทษให้ weights ขนาดใหญ่:

$$
\underset{w,b}{\operatorname{minimize}}
\left[
\sum_{i=1}^{n}(y_i-\hat{y}_i)^2
+\alpha\sum_{j=1}^{p}w_j^2
\right]
$$

$\alpha$ สูงขึ้นจะกด weights มากขึ้น ถ้าสูงเกินไปโมเดลอาจเรียนรู้น้อยเกินไป จึงควรเลือกด้วย Validation หรือ Cross-validation

## 8. Logistic Regression และ Classification

คะแนนเชิงเส้นและ Sigmoid:

$$
s=b+w_1x_1+w_2x_2+\cdots+w_px_p
$$

$$
p=\sigma(s)=\frac{1}{1+e^{-s}}
$$

การแปลง Probability เป็นคลาสด้วย Threshold $\tau$:

$$
\hat{y}=
\begin{cases}
1,&p\ge\tau\\
0,&p<\tau
\end{cases}
$$

Binary Log Loss สำหรับหนึ่งแถว:

$$
L_i=-\left[y_i\log(p_i)+(1-y_i)\log(1-p_i)\right]
$$

ค่าเฉลี่ยทั้งชุด:

$$
\mathrm{LogLoss}=-\frac{1}{n}\sum_{i=1}^{n}
\left[y_i\log(p_i)+(1-y_i)\log(1-p_i)\right]
$$

ยิ่งต่ำยิ่งดี และการทายผิดอย่างมั่นใจจะถูกลงโทษมาก สำหรับหลายคลาสเลือกคลาสที่มี Probability สูงสุด:

$$
\hat{y}=\underset{k}{\operatorname{argmax}}\;P(y=c_k\mid x)
$$

## 9. Classification metrics

| ค่า | ความหมาย |
|---|---|
| TP | ทาย Positive และจริงเป็น Positive |
| TN | ทาย Negative และจริงเป็น Negative |
| FP | ทาย Positive แต่จริงเป็น Negative |
| FN | ทาย Negative แต่จริงเป็น Positive |

$$
\mathrm{Accuracy}=\frac{TP+TN}{TP+TN+FP+FN}
$$

$$
\mathrm{Precision}=\frac{TP}{TP+FP}
$$

$$
\mathrm{Recall}=\frac{TP}{TP+FN}
$$

$$
\mathrm{Specificity}=\frac{TN}{TN+FP}
$$

$$
F_1=\frac{2\times\mathrm{Precision}\times\mathrm{Recall}}
{\mathrm{Precision}+\mathrm{Recall}}
$$

ถ้าตัวหารเป็นศูนย์ต้องกำหนดวิธีรายงานให้ชัดเจน เช่น ใช้พารามิเตอร์ `zero_division` ของ scikit-learn

น้ำหนักเมื่อใช้ `class_weight="balanced"`:

$$
w_k=\frac{n}{K n_k}
$$

$n_k$ คือจำนวนตัวอย่างในคลาส $k$ คลาสที่พบน้อยจึงได้น้ำหนักมากขึ้น

### ROC และ Probability Calibration

$$
\mathrm{TPR}=\frac{TP}{TP+FN},\qquad
\mathrm{FPR}=\frac{FP}{FP+TN}
$$

$$
\mathrm{Brier}=\frac{1}{n}\sum_{i=1}^{n}(p_i-y_i)^2
$$

Brier score ยิ่งต่ำยิ่งดี แต่ควรดู Calibration curve ร่วมด้วย

## 10. Decision Tree

Gini Impurity:

$$
\operatorname{Gini}(Q)=1-\sum_{k=1}^{K}p_k^2
$$

ถ่วงน้ำหนักความปะปนหลังแบ่ง และหาค่าที่ลดลง:

$$
I_{\text{after}}=\frac{N_L}{N}I(L)+\frac{N_R}{N}I(R)
$$

$$
\Delta I=I(\text{parent})-I_{\text{after}}
$$

Entropy และ Information Gain:

$$
H(Q)=-\sum_{k=1}^{K}p_k\log_2(p_k)
$$

$$
\mathrm{Information\ Gain}=H(\text{parent})-H_{\text{after}}
$$

เมื่อ $p_k=0$ ให้ถือว่าพจน์ $p_k\log_2(p_k)$ มีค่า 0

MSE ภายในโหนด Regression:

$$
\mathrm{MSE}_{\text{node}}=\frac{1}{N}\sum_{i=1}^{N}(y_i-\bar{y})^2
$$

ค่าทำนายของ Regression Leaf และ Probability ของ Classification Leaf:

$$
\hat{y}_{\text{leaf}}=\frac{1}{N_{\text{leaf}}}\sum_{i\in\text{leaf}}y_i
$$

$$
P(y=c_k\mid\text{leaf})=\frac{N_k}{N_{\text{leaf}}}
$$

Cost-complexity pruning:

$$
R_\alpha(T)=R(T)+\alpha|\widetilde{T}|
$$

$R(T)$ คือความผิดพลาด และ $|\widetilde{T}|$ คือจำนวน Leaves ค่า $\alpha$ สูงขึ้นจึงสนับสนุนต้นไม้ที่เล็กลง

## 11. Random Forest

แนวคิดแบบโหวตสำหรับ Classification:

$$
N_c=\sum_{t=1}^{T}\mathbf{1}(\hat{y}_t=c)
$$

$$
\hat{y}=\underset{c}{\operatorname{argmax}}\;N_c
$$

ใน `RandomForestClassifier` ของ scikit-learn การทำนายจริงจะเฉลี่ย Probability ของแต่ละต้น แล้วเลือกคลาสที่มีค่าเฉลี่ยสูงสุด:

$$
\bar{P}(y=c\mid x)=\frac{1}{T}\sum_{t=1}^{T}P_t(y=c\mid x)
$$

Regression ใช้ค่าเฉลี่ยคำทำนาย:

$$
\hat{y}=\frac{1}{T}\sum_{t=1}^{T}\hat{y}_t
$$

โอกาสที่แถวหนึ่งไม่ถูกเลือกในการสุ่ม Bootstrap $n$ ครั้ง:

$$
P(\text{OOB})=\left(1-\frac{1}{n}\right)^n
\approx e^{-1}\approx0.368
$$

จึงมีข้อมูลประมาณ 36.8% เป็น OOB สำหรับต้นไม้หนึ่งต้นเมื่อ $n$ มีค่ามาก

$$
\mathrm{OOB\ Accuracy}=
\frac{\text{จำนวนแถวที่ทำนาย OOB ถูก}}
{\text{จำนวนแถวที่มีคำทำนาย OOB}}
$$

## 12. Gradient Boosting

สำหรับ Squared Error ค่าเริ่มต้นมักเป็นค่าเฉลี่ยของ Target:

$$
F_0(x)=\bar{y}
$$

Residual ในรอบที่ $m$ และการอัปเดตโมเดล:

$$
r_i^{(m)}=y_i-F_{m-1}(x_i)
$$

$$
F_m(x)=F_{m-1}(x)+\eta h_m(x)
$$

เมื่อรวม $M$ รอบ:

$$
F_M(x)=F_0(x)+\eta\sum_{m=1}^{M}h_m(x)
$$

$\eta$ ต่ำทำให้แต่ละต้นแก้ทีละน้อยและมักต้องใช้ต้นไม้มากขึ้น

## 13. Feature Engineering และ Explainability

### Fuzzy Matching

Levenshtein Distance คือจำนวนการเพิ่ม ลบ หรือแทนที่ตัวอักษรขั้นต่ำ เพื่อเปลี่ยนข้อความ $a$ เป็น $b$:

$$
d(a,b)=\text{จำนวนการแก้ไขขั้นต่ำจาก }a\text{ ไปเป็น }b
$$

ตัดสินการจับคู่ด้วยคะแนนและ Threshold $\tau$:

$$
\text{match}=
\begin{cases}
1, & \text{score}\geq\tau\\
0, & \text{score}<\tau
\end{cases}
$$

ดูวิธีเลือก Scorer และ Threshold ที่ [Fuzzy Matching](fuzzy-matching.md)

### วันที่และเวลา

ระยะเวลาระหว่างสองเหตุการณ์:

$$
\Delta t=t_{\text{end}}-t_{\text{start}}
$$

ข้อมูลที่วนเป็นรอบ เช่น เดือนหรือวันในสัปดาห์ สามารถแปลงเป็นคู่ Sine/Cosine:

$$
x_{\sin}=\sin\left(2\pi\frac{x}{P}\right)
$$

$$
x_{\cos}=\cos\left(2\pi\frac{x}{P}\right)
$$

$P$ คือความยาวหนึ่งรอบ เช่น $12$ สำหรับเดือน ดูตัวอย่างที่ [Parsing Dates](parsing-dates.md)

### PCA

สัดส่วนความแปรปรวนที่ Principal component $j$ อธิบายได้:

$$
r_j=\frac{\lambda_j}{\sum_{k=1}^{p}\lambda_k}
$$

$\lambda_j$ คือ Explained variance ของ Component $j$

### K-Means

ระยะทางแบบ Euclidean สำหรับข้อมูล $p$ Features:

$$
d(x,\mu_k)=\sqrt{\sum_{j=1}^{p}(x_j-\mu_{k,j})^2}
$$

เลือกกลุ่มที่มี Centroid ใกล้ที่สุด:

$$
c_i=\underset{k}{\operatorname{argmin}}\;\|x_i-\mu_k\|^2
$$

Centroid ของกลุ่ม $k$:

$$
\mu_k=\frac{1}{|C_k|}\sum_{x_i\in C_k}x_i
$$

Inertia:

$$
\mathrm{Inertia}
=\sum_{k=1}^{K}\sum_{x_i\in C_k}\|x_i-\mu_k\|^2
$$

Silhouette Score ของข้อมูลแถวที่ $i$:

$$
s(i)=\frac{b(i)-a(i)}{\max(a(i),b(i))}
$$

$a(i)$ คือระยะเฉลี่ยภายในกลุ่ม และ $b(i)$ คือระยะเฉลี่ยต่ำที่สุดไปยังกลุ่มอื่น

### SVM

คะแนนของ Linear SVM และการทำนาย:

$$
f(x)=w^Tx+b,qquad
\hat{y}=\operatorname{sign}(w^Tx+b)
$$

Soft-margin objective:

$$
\underset{w,b,\xi}{\operatorname{minimize}}
\left[\frac{1}{2}\|w\|^2+C\sum_{i=1}^{n}\xi_i\right]
$$

RBF kernel:

$$
K(x,z)=\exp\left(-\gamma\|x-z\|^2\right)
$$

### KNN

Euclidean distance และค่าทำนาย Regression:

$$
d(x,z)=\sqrt{\sum_{j=1}^{p}(x_j-z_j)^2}
$$

$$
\hat{y}=\frac{1}{K}\sum_{i\in N_K(x)}y_i
$$

### Naive Bayes

กฎของ Bayes:

$$
P(C\mid X)=\frac{P(X\mid C)P(C)}{P(X)}
$$

เมื่อสมมติว่า Features เป็นอิสระต่อกันเมื่อทราบคลาส:

$$
\hat{C}=\underset{c}{\operatorname{argmax}}
\;P(C=c)\prod_{j=1}^{p}P(x_j\mid C=c)
$$

### Neural Network

Neuron, Activation และ Gradient descent:

$$
z=w^Tx+b,qquad a=g(z)
$$

$$
w\leftarrow w-\eta\frac{\partial L}{\partial w}
$$

Softmax:

$$
P(y=k\mid x)=\frac{e^{z_k}}{\sum_{j=1}^{K}e^{z_j}}
$$

### Transformer

Scaled dot-product attention:

$$
\operatorname{Attention}(Q,K,V)
=\operatorname{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V
$$

Cross-entropy สำหรับการทำนาย Token และ Perplexity:

$$
L=-\frac{1}{N}\sum_{i=1}^{N}\log P(y_i\mid x_{\le i})
$$

$$
\mathrm{Perplexity}=e^L
$$

### Encoding และ Decoding

Frequency Encoding ของ Category $c$:

$$
\operatorname{freq}(c)=\frac{n_c}{n}
$$

Target Encoding แบบค่าเฉลี่ย:

$$
\operatorname{TE}(c)
=\frac{1}{n_c}\sum_{i:x_i=c}y_i
$$

Target Encoding ต้องสร้างจาก Train และควรใช้ Out-of-fold encoding เพื่อลด Target Leakage

Autoencoder เรียนรู้ Latent representation แล้วสร้าง Input กลับ:

$$
z=f_{\text{encoder}}(x),\qquad
\hat{x}=g_{\text{decoder}}(z)
$$

$$
L=\frac{1}{n}\sum_{i=1}^{n}\|x_i-\hat{x}_i\|^2
$$

### อัตราส่วนและ Interaction

$$
x_{\text{ratio}}=\frac{x_a}{x_b}
$$

$$
x_{\text{interaction}}=x_1x_2
$$

ต้องจัดการกรณี $x_b=0$ เสมอ

Permutation Importance ของ Feature $j$:

$$
I_j=s-\frac{1}{K}\sum_{k=1}^{K}s_{k,j}
$$

$s$ คือคะแนนก่อนสลับค่า และ $s_{k,j}$ คือคะแนนหลังสุ่มสลับ Feature $j$ รอบที่ $k$ ค่าสูงหมายถึงโมเดลพึ่ง Feature นั้นมาก แต่ไม่ได้ยืนยันความเป็นเหตุเป็นผล

### Time Series baseline

$$
\hat{y}_t=y_{t-1}
$$

$$
\hat{y}_t=y_{t-s}
$$

สูตรแรกใช้ค่าก่อนหน้า ส่วนสูตรที่สองใช้ค่าจากฤดูกาลก่อน โดย $s$ คือความยาวฤดูกาล

## 14. เลือกสูตรไหนดี?

| เป้าหมาย | สูตรหรือ Metric ที่เริ่มใช้ได้ |
|---|---|
| รู้ว่าพลาดเฉลี่ยกี่หน่วย | MAE |
| ลงโทษค่าที่พลาดมาก | MSE หรือ RMSE |
| รายงานเป็นเปอร์เซ็นต์และ Target ไม่ใกล้ศูนย์ | MAPE |
| เทียบ Regression กับ Baseline ค่าเฉลี่ย | $R^2$ |
| Classification ที่คลาสสมดุลและต้นทุนใกล้กัน | Accuracy |
| ลด False Positive | Precision |
| ลด False Negative | Recall |
| สมดุล Precision กับ Recall | F1 |
| ประเมินคุณภาพ Probability | Log Loss |

> [!IMPORTANT]
> เริ่มจากถามว่า “ความผิดพลาดแบบใดสร้างผลเสียมากที่สุดในงานนี้” แล้วจึงเลือก Metric และ Threshold

## 15. ตัวอย่าง Python: เขียนสูตรพื้นฐาน

```python
from math import exp, sqrt


def mean(values):
    return sum(values) / len(values)


def mae(y_true, y_pred):
    return mean([abs(a - p) for a, p in zip(y_true, y_pred)])


def mse(y_true, y_pred):
    return mean([(a - p) ** 2 for a, p in zip(y_true, y_pred)])


def rmse(y_true, y_pred):
    return sqrt(mse(y_true, y_pred))


def sigmoid(score):
    return 1 / (1 + exp(-score))


def precision(tp, fp):
    return tp / (tp + fp) if tp + fp else 0.0


def recall(tp, fn):
    return tp / (tp + fn) if tp + fn else 0.0


def f1(precision_value, recall_value):
    total = precision_value + recall_value
    return 2 * precision_value * recall_value / total if total else 0.0


y_true = [3, 5]
y_pred = [2, 7]
p = precision(tp=15, fp=5)
r = recall(tp=15, fn=15)

print("MAE:", mae(y_true, y_pred))
print("MSE:", mse(y_true, y_pred))
print("RMSE:", rmse(y_true, y_pred))
print("Sigmoid(2):", sigmoid(2))
print("F1:", f1(p, r))
```

โค้ดนี้เขียนตามสูตรเพื่อช่วยให้เข้าใจ ในงานจริงควรใช้ฟังก์ชันจาก `scikit-learn` ซึ่งรองรับรายละเอียดและกรณีพิเศษมากกว่า

## แหล่งอ้างอิง

- [scikit-learn: Model evaluation](https://scikit-learn.org/stable/modules/model_evaluation.html)
- [scikit-learn: Preprocessing data](https://scikit-learn.org/stable/modules/preprocessing.html)
- [scikit-learn: Logistic regression](https://scikit-learn.org/stable/modules/linear_model.html#logistic-regression)
- [scikit-learn: Decision Trees](https://scikit-learn.org/stable/modules/tree.html)
- [scikit-learn: Ensemble methods](https://scikit-learn.org/stable/modules/ensemble.html)

---

[สารบัญ](index.md)
