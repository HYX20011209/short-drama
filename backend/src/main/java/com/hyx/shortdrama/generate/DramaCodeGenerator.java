package com.hyx.shortdrama.generate;

import cn.hutool.core.io.FileUtil;
import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.io.FileWriter;
import java.io.Writer;

/**
 * 剧集相关代码生成器
 */
public class DramaCodeGenerator {

    public static void main(String[] args) throws TemplateException, IOException {
        generateDramaCode();
        generateWatchHistoryCode();
        generateUserDramaFavoriteCode();
    }

    /**
     * 生成Drama相关代码
     */
    public static void generateDramaCode() throws TemplateException, IOException {
        String packageName = "com.hyx.shortdrama";
        String dataName = "剧集";
        String dataKey = "drama";
        String upperDataKey = "Drama";

        Map<String, Object> dataModel = new HashMap<>();
        dataModel.put("packageName", packageName);
        dataModel.put("dataName", dataName);
        dataModel.put("dataKey", dataKey);
        dataModel.put("upperDataKey", upperDataKey);

        String projectPath = System.getProperty("user.dir");

        // 1. 生成Controller
        String inputPath = projectPath + File.separator + "src/main/resources/templates/TemplateController.java.ftl";
        String outputPath = String.format("%s/generator/controller/%sController.java", projectPath, upperDataKey);
        doGenerate(inputPath, outputPath, dataModel);
        System.out.println("生成 DramaController 成功");

        // 2. 生成Service接口和实现类
        inputPath = projectPath + File.separator + "src/main/resources/templates/TemplateService.java.ftl";
        outputPath = String.format("%s/generator/service/%sService.java", projectPath, upperDataKey);
        doGenerate(inputPath, outputPath, dataModel);
        System.out.println("生成 DramaService 成功");

        inputPath = projectPath + File.separator + "src/main/resources/templates/TemplateServiceImpl.java.ftl";
        outputPath = String.format("%s/generator/service/impl/%sServiceImpl.java", projectPath, upperDataKey);
        doGenerate(inputPath, outputPath, dataModel);
        System.out.println("生成 DramaServiceImpl 成功");

        // 3. 生成DTO
        generateDramaDTO(projectPath, dataModel);

        // 4. 生成VO
        inputPath = projectPath + File.separator + "src/main/resources/templates/model/DramaVO.java.ftl";
        outputPath = String.format("%s/generator/model/vo/%sVO.java", projectPath, upperDataKey);
        doGenerate(inputPath, outputPath, dataModel);
        System.out.println("生成 DramaVO 成功");
    }

    private static void generateDramaDTO(String projectPath, Map<String, Object> dataModel) throws TemplateException, IOException {
        String upperDataKey = (String) dataModel.get("upperDataKey");

        // 使用专门的Drama模板
        String inputPath = projectPath + File.separator + "src/main/resources/templates/model/DramaAddRequest.java.ftl";
        String outputPath = String.format("%s/generator/model/dto/drama/%sAddRequest.java", projectPath, upperDataKey);
        doGenerate(inputPath, outputPath, dataModel);

        // 其他DTO使用通用模板
        inputPath = projectPath + File.separator + "src/main/resources/templates/model/TemplateQueryRequest.java.ftl";
        outputPath = String.format("%s/generator/model/dto/drama/%sQueryRequest.java", projectPath, upperDataKey);
        doGenerate(inputPath, outputPath, dataModel);

        inputPath = projectPath + File.separator + "src/main/resources/templates/model/TemplateEditRequest.java.ftl";
        outputPath = String.format("%s/generator/model/dto/drama/%sEditRequest.java", projectPath, upperDataKey);
        doGenerate(inputPath, outputPath, dataModel);

        inputPath = projectPath + File.separator + "src/main/resources/templates/model/TemplateUpdateRequest.java.ftl";
        outputPath = String.format("%s/generator/model/dto/drama/%sUpdateRequest.java", projectPath, upperDataKey);
        doGenerate(inputPath, outputPath, dataModel);

        System.out.println("生成 Drama DTO 成功");
    }

    /**
     * 生成WatchHistory相关代码
     */
    public static void generateWatchHistoryCode() throws TemplateException, IOException {
        String packageName = "com.hyx.shortdrama";
        String dataName = "观看历史";
        String dataKey = "watchHistory";
        String upperDataKey = "WatchHistory";

        Map<String, Object> dataModel = new HashMap<>();
        dataModel.put("packageName", packageName);
        dataModel.put("dataName", dataName);
        dataModel.put("dataKey", dataKey);
        dataModel.put("upperDataKey", upperDataKey);

        String projectPath = System.getProperty("user.dir");

        // 生成Service (WatchHistory不需要Controller，通过UserController访问)
        String inputPath = projectPath + File.separator + "src/main/resources/templates/TemplateService.java.ftl";
        String outputPath = String.format("%s/generator/service/%sService.java", projectPath, upperDataKey);
        doGenerate(inputPath, outputPath, dataModel);

        inputPath = projectPath + File.separator + "src/main/resources/templates/TemplateServiceImpl.java.ftl";
        outputPath = String.format("%s/generator/service/impl/%sServiceImpl.java", projectPath, upperDataKey);
        doGenerate(inputPath, outputPath, dataModel);

        // 生成VO
        inputPath = projectPath + File.separator + "src/main/resources/templates/model/TemplateVO.java.ftl";
        outputPath = String.format("%s/generator/model/vo/%sVO.java", projectPath, upperDataKey);
        doGenerate(inputPath, outputPath, dataModel);

        System.out.println("生成 WatchHistory 相关代码成功");
    }

    /**
     * 生成UserDramaFavorite相关代码
     */
    public static void generateUserDramaFavoriteCode() throws TemplateException, IOException {
        String packageName = "com.hyx.shortdrama";
        String dataName = "用户剧集收藏";
        String dataKey = "userDramaFavorite";
        String upperDataKey = "UserDramaFavorite";

        Map<String, Object> dataModel = new HashMap<>();
        dataModel.put("packageName", packageName);
        dataModel.put("dataName", dataName);
        dataModel.put("dataKey", dataKey);
        dataModel.put("upperDataKey", upperDataKey);

        String projectPath = System.getProperty("user.dir");

        // 生成Service (不需要Controller)
        String inputPath = projectPath + File.separator + "src/main/resources/templates/TemplateService.java.ftl";
        String outputPath = String.format("%s/generator/service/%sService.java", projectPath, upperDataKey);
        doGenerate(inputPath, outputPath, dataModel);

        inputPath = projectPath + File.separator + "src/main/resources/templates/TemplateServiceImpl.java.ftl";
        outputPath = String.format("%s/generator/service/impl/%sServiceImpl.java", projectPath, upperDataKey);
        doGenerate(inputPath, outputPath, dataModel);

        System.out.println("生成 UserDramaFavorite 相关代码成功");
    }

    /**
     * 生成文件
     */
    public static void doGenerate(String inputPath, String outputPath, Object model) throws IOException, TemplateException {
        Configuration configuration = new Configuration(Configuration.VERSION_2_3_31);
        File templateDir = new File(inputPath).getParentFile();
        configuration.setDirectoryForTemplateLoading(templateDir);
        configuration.setDefaultEncoding("utf-8");

        String templateName = new File(inputPath).getName();
        Template template = configuration.getTemplate(templateName);

        if (!FileUtil.exist(outputPath)) {
            FileUtil.touch(outputPath);
        }

        Writer out = new FileWriter(outputPath);
        template.process(model, out);
        out.close();
    }
}